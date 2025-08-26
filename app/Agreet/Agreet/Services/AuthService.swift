import Foundation
import Supabase
import Combine

/// Service responsible for managing authentication state and operations
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let supabase = SupabaseService.shared
    
    /// Published property to track authentication state
    @Published private(set) var isAuthenticated = false
    
    /// The current user
    @Published private(set) var currentUser: User?
    
    /// Authentication error state
    @Published private(set) var authError: Error?
    
    // Published property to track if initial auth check has completed
    @Published private(set) var isInitialized = false
    
    // Task to track ongoing authentication
    private var authTask: Task<Void, Never>?
    
    // Actor for thread-safe access to authentication state
    private actor AuthState {
        var isAuthenticating = false
        
        func startAuthenticating() -> Bool {
            if isAuthenticating {
                return false
            }
            isAuthenticating = true
            return true
        }
        
        func finishAuthenticating() {
            isAuthenticating = false
        }
    }
    
    private let authState = AuthState()
    
    // Completion handler for waiting for auth to complete
    private var authCompletion = PassthroughSubject<Bool, Never>()
    
    private init() {
        // Start authentication process on init
        startAuthenticationProcess()
    }
    
    private func startAuthenticationProcess() {
        // Cancel any existing auth task
        authTask?.cancel()
        
        // Create a new auth task
        authTask = Task {
            do {
                print("Starting authentication process")
                await checkSession()
                try await performAuthenticationIfNeeded()
                
                // Mark as initialized only after successful auth
                await MainActor.run {
                    self.isInitialized = true
                    print("Authentication completed successfully")
                    self.authCompletion.send(true)
                }
            } catch {
                print("Authentication process failed: \(error.localizedDescription)")
                
                // Try again after a delay if task wasn't cancelled
                if !(error is CancellationError) {
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                    startAuthenticationProcess()  // Retry
                }
            }
        }
    }
    
    /// Returns a publisher that completes when authentication is done
    var authenticationCompleted: AnyPublisher<Bool, Never> {
        return authCompletion.eraseToAnyPublisher()
    }
    
    /// Ensures the user is authenticated, preventing concurrent attempts
    func performAuthenticationIfNeeded() async throws {
        if !isAuthenticated {
            // Try to start authentication using our actor for thread safety
            if await authState.startAuthenticating() {
                // We got permission to authenticate
                do {
                    // Use defer to ensure we always mark auth as finished
                    defer {
                        Task {
                            // Need to use Task because await in defer is not allowed
                            await authState.finishAuthenticating()
                        }
                    }
                    
                    print("Performing authentication")
                    try await signInAnonymously()
                }
            } else {
                // Another auth attempt is already in progress, wait for it
                print("Auth already in progress, waiting...")
                try await Task.sleep(nanoseconds: 100_000_000)
                return try await performAuthenticationIfNeeded()
            }
        }
    }
    
    /// Checks if there's a valid session and updates authentication state
    @MainActor
    func checkSession() async {
        // Check if user is already signed in
        if let session = try? await supabase.supabase.auth.session, session.isExpired == false {
            isAuthenticated = true
            let userFetched = await fetchCurrentUser()
            
            // If session is valid but user doesn't exist in database (e.g., user was deleted on backend),
            // we need to sign out and start fresh
            if !userFetched {
                print("Valid session found but user doesn't exist in database. Signing out and starting fresh.")
                await signOut()
                // The authentication process will retry and create a new anonymous session
            }
        } else {
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    /// Signs in anonymously and updates authentication state
    @MainActor
    func signInAnonymously() async throws {
        do {
            // Use the existing method from SupabaseService but mark as throwing
            try await supabase.signInAnonymouslyIfNeeded()
            
            // Update authentication state
            isAuthenticated = true
            
            // Fetch user details
            let userFetched = await fetchCurrentUser()
            
            // If user fetch failed after successful sign-in, something is wrong
            if !userFetched {
                print("Warning: Anonymous sign-in succeeded but user fetch failed")
                // Don't throw here as the sign-in was successful, just log the warning
            }
            
        } catch {
            isAuthenticated = false
            currentUser = nil
            authError = error
            print("Error signing in anonymously: \(error)")
            throw error
        }
    }
    
    /// Signs out the current user
    @MainActor
    func signOut() async {
        do {
            try await supabase.supabase.auth.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            authError = error
            print("Error signing out: \(error)")
        }
    }
    
    /// Fetches the current user's profile from the database
    /// Returns true if user was successfully fetched, false otherwise
    @MainActor
    private func fetchCurrentUser() async -> Bool {
        do {
            guard let authUser = try? await supabase.supabase.auth.user() else {
                print("No authenticated user found")
                return false
            }
            
            // Fetch the user profile from the database using the auth user's ID
            let response = try await supabase.supabase.from("users")
                .select()
                .eq("id", value: authUser.id)
                .single()
                .execute()
                
            // Handle the response data and decode manually
            do {
                let data = response.data
                if !data.isEmpty {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    self.currentUser = user
                    return true
                } else {
                    print("No user data returned from the database")
                    return false
                }
            } catch {
                print("Failed to decode user data: \(error)")
                return false
            }
        } catch {
            print("Error fetching user profile: \(error)")
            return false
        }
    }
    
    /// Updates the username for the current user
    @MainActor
    func updateUsername(_ username: String) async -> Bool {
        guard isAuthenticated, let userId = currentUser?.id else {
            return false
        }
        
        do {
            struct UpdatePayload: Codable {
                let username: String
            }
            
            let payload = UpdatePayload(username: username)
            
            let response = try await supabase.supabase.from("users")
                .update(payload)
                .eq("id", value: userId)
                .execute()
            
            if response.status == 200 || response.status == 201 {
                // Update local user object
                var updatedUser = currentUser
                updatedUser?.username = username
                currentUser = updatedUser
                return true
            }
            return false
        } catch {
            print("Error updating username: \(error)")
            return false
        }
    }
    
    /// Updates the APNS token for push notifications
    @MainActor
    func updateAPNSToken(_ token: String?) async {
        guard isAuthenticated, let userId = currentUser?.id else {
            return
        }
        
        do {
            // Create a proper Codable payload
            struct TokenPayload: Codable {
                let apns_token: String?
            }
            
            let payload = TokenPayload(apns_token: token)
            
            _ = try await supabase.supabase.from("users")
                .update(payload)
                .eq("id", value: userId)
                .execute()
            
            // Update local user object
            var updatedUser = currentUser
            updatedUser?.apnsToken = token
            currentUser = updatedUser
        } catch {
            print("Error updating APNS token: \(error)")
        }
    }
}

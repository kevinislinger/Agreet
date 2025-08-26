import Foundation
import Combine

class JoinSessionViewModel: ObservableObject {
    // Input
    @Published var inviteCode: String = ""
    
    // States
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var joinedSession: Session?
    
    // Services
    private let networkService = NetworkService.shared
    private let sessionService = SessionService.shared
    
    @MainActor
    func joinSession() async -> Bool {
        // Basic validation
        let trimmedCode = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedCode.isEmpty {
            errorMessage = "Please enter an invite code"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await networkService.joinSession(inviteCode: trimmedCode)
            joinedSession = session
            
            // Set as current session in the session service
            sessionService.setCurrentSession(session)
            
            isLoading = false
            return true
        } catch {
            isLoading = false
            
            // Handle specific error types for better messaging
            if let networkError = error as? NetworkError {
                switch networkError {
                case .sessionAlreadyMatched:
                    errorMessage = "This session already has a match"
                case .sessionClosed:
                    errorMessage = "This session is closed"
                case .alreadyJoined:
                    errorMessage = "You have already joined this session"
                case .sessionFull:
                    errorMessage = "This session is full"
                case .notFound:
                    errorMessage = "Invalid invite code"
                default:
                    errorMessage = "Failed to join session: \(networkError.localizedDescription)"
                }
            } else {
                errorMessage = "Failed to join session: \(error.localizedDescription)"
            }
            return false
        }
    }
}

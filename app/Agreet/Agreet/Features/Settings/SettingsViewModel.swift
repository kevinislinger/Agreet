import Foundation
import SwiftUI
import UserNotifications
import UIKit

@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isEditingUsername = false
    @Published var editingUsername = ""
    @Published var pushNotificationsEnabled = false
    
    // Alert states
    @Published var showErrorAlert = false
    @Published var showSuccessAlert = false
    @Published var errorMessage = ""
    @Published var successMessage = ""
    
    // MARK: - Private Properties
    private let authService = AuthService.shared
    private let notificationService = NotificationService.shared
    
    // MARK: - Computed Properties
    var currentUsername: String {
        return authService.currentUser?.username ?? "Unknown User"
    }
    
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0.0"
    }
    
    var memberSinceText: String {
        guard let createdAt = authService.currentUser?.createdAt else {
            return "Unknown"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: createdAt)
    }
    
    // MARK: - Initialization
    init() {
        loadUserData()
    }
    
    // MARK: - Public Methods
    
    /// Loads user data and notification preferences
    func loadUserData() {
        // Load username
        editingUsername = currentUsername
        
        // Load notification preferences
        Task {
            await loadNotificationPreferences()
        }
    }
    
    /// Refreshes notification preferences (call this when returning from iOS Settings)
    func refreshNotificationPreferences() {
        Task {
            await loadNotificationPreferences()
        }
    }
    
    /// Starts editing the username
    func startUsernameEdit() {
        editingUsername = currentUsername
        isEditingUsername = true
    }
    
    /// Cancels username editing
    func cancelUsernameEdit() {
        editingUsername = currentUsername
        isEditingUsername = false
    }
    
    /// Saves the new username
    func saveUsername() async {
        guard !editingUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError(message: "Username cannot be empty")
            return
        }
        
        let trimmedUsername = editingUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if username is different from current
        if trimmedUsername == currentUsername {
            isEditingUsername = false
            return
        }
        
        // Validate username format
        if !isValidUsername(trimmedUsername) {
            showError(message: "Username can only contain letters, numbers, and underscores")
            return
        }
        
        // Update username in backend
        let success = await authService.updateUsername(trimmedUsername)
        
        if success {
            isEditingUsername = false
            showSuccess(message: "Username updated successfully")
        } else {
            showError(message: "Failed to update username. Please try again.")
        }
    }
    
    /// Opens iOS Settings for the app
    func openNotificationSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    /// Signs out the current user
    func signOut() async {
        await authService.signOut()
        // The app will handle navigation back to authentication
    }
    
    /// Shows help and support
    func showHelp() {
        // This could open a help URL or show a help sheet
        // For now, we'll just show an alert
        showSuccess(message: "Help & Support coming soon!")
    }
    
    /// Shows privacy policy
    func showPrivacyPolicy() {
        // This could open a privacy policy URL
        // For now, we'll just show an alert
        showSuccess(message: "Privacy Policy coming soon!")
    }
    
    // MARK: - Private Methods
    
    /// Loads notification preferences from iOS system and syncs with backend
    private func loadNotificationPreferences() async {
        // Use NotificationService to check permissions and sync with backend
        await notificationService.checkPermissionsAndSync()
        
        // Update local state based on authorization status
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        await MainActor.run {
            self.pushNotificationsEnabled = settings.authorizationStatus == .authorized
        }
    }
    
    /// Validates username format
    private func isValidUsername(_ username: String) -> Bool {
        // Username should be 3-20 characters, alphanumeric and underscores only
        let usernameRegex = "^[a-zA-Z0-9_]{3,20}$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        return usernamePredicate.evaluate(with: username)
    }
    
    /// Shows an error alert
    private func showError(message: String) {
        errorMessage = message
        showErrorAlert = true
    }
    
    /// Shows a success alert
    private func showSuccess(message: String) {
        successMessage = message
        showSuccessAlert = true
    }
}

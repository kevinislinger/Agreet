import Foundation
import SwiftUI
import UserNotifications
import UIKit
import Supabase

class NotificationService: NSObject {
    static let shared = NotificationService()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Public Methods
    
    /// Request authorization for push notifications
    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            print("Error requesting notification authorization: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Register for remote notifications with APNs
    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    /// Update the APNs token in Supabase when it's received or changes
    func updateAPNsToken(_ deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        // Call the Supabase RPC function to update the token
        Task {
            do {
                try await SupabaseService.shared.supabase.rpc(
                    "update_apns_token",
                    params: ["p_token": token]
                ).execute()
                print("Successfully updated APNs token")
            } catch {
                print("Failed to update APNs token: \(error.localizedDescription)")
            }
        }
    }
    
    /// Handle a match notification when received
    func handleMatchNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard let sessionId = userInfo["session_id"] as? String,
              let matchedOptionId = userInfo["matched_option_id"] as? String else {
            print("Invalid match notification payload")
            return false
        }
        
        // Post notification to update UI
        NotificationCenter.default.post(
            name: Notification.Name("MatchFound"),
            object: nil,
            userInfo: [
                "session_id": sessionId,
                "matched_option_id": matchedOptionId
            ]
        )
        
        return true
    }
    
    /// Clear device token when user disables notifications
    func clearDeviceToken() async {
        do {
            try await SupabaseService.shared.supabase.rpc(
                "update_apns_token",
                params: ["p_token": ""]
            ).execute()
            print("Successfully cleared APNs token")
        } catch {
            print("Failed to clear APNs token: \(error.localizedDescription)")
        }
    }
    
    /// Check current notification permissions and sync with backend
    func checkPermissionsAndSync() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        if settings.authorizationStatus == .authorized {
            // If authorized, we'll wait for the APNS token to be received
            // The system will call updateAPNsToken when the token arrives
            print("Notifications authorized - waiting for APNS token")
        } else {
            // If not authorized, clear the token in backend
            print("Notifications not authorized - clearing APNS token in backend")
            await clearDeviceToken()
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               willPresent notification: UNNotification, 
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               didReceive response: UNNotificationResponse, 
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap
        let userInfo = response.notification.request.content.userInfo
        _ = handleMatchNotification(userInfo)
        completionHandler()
    }
}

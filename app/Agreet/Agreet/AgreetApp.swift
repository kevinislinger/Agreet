//
//  AgreetApp.swift
//  Agreet
//
//  Created by Kevin on 25.08.25.
//

import SwiftUI
import UIKit

@main
struct AgreetApp: App {
    // Create environment objects
    @StateObject private var authService = AuthService.shared
    @StateObject private var sessionService = SessionService.shared
    
    // App delegate for push notifications
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    init() {
        // Perform initial setup
        Task {
            // Attempt to sign in anonymously if needed when the app launches
            await AuthService.shared.signInAnonymously()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(sessionService)
                .onAppear {
                    // Request push notification permission
                    Task {
                        let authorized = await NotificationService.shared.requestAuthorization()
                        if authorized {
                            NotificationService.shared.registerForRemoteNotifications()
                        }
                    }
                }
                // Listen for match notifications
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("MatchFound"))) { notification in
                    guard let _ = notification.userInfo?["session_id"] as? String,
                          let _ = notification.userInfo?["matched_option_id"] as? String else {
                        return
                    }
                    
                    // Update the session in the session service
                    Task {
                        await sessionService.refreshOpenSessions()
                        await sessionService.refreshClosedSessions()
                        // Handle navigation to results screen will be done by the view observing sessionService
                    }
                }
        }
    }
}

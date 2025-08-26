//
//  ContentView.swift
//  Agreet
//
//  Created by Kevin on 25.08.25.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isAuthComplete = false
    
    // Store subscription to prevent it from being canceled
    @State private var subscription: AnyCancellable?
    
    var body: some View {
        Group {
            if !isAuthComplete {
                // Loading view while waiting for auth initialization
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                    Text("Initializing...")
                        .foregroundColor(Color.themeTextSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.themeBackground)
                .onAppear {
                    // Subscribe to auth completion
                    subscription = authService.authenticationCompleted
                        .receive(on: RunLoop.main)
                        .sink { _ in
                            // Only show content when auth is fully complete
                            isAuthComplete = true
                        }
                }
            } else if authService.isAuthenticated {
                LandingView()
            } else {
                AuthView()
            }
        }
    }
}

struct AuthView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 30) {
                    // App logo
                    Image(systemName: "checkmark.circle.fill") // Replace with your app logo
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.themeAccent)
                    
                    Text("Welcome to Agreet")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.themeTextPrimary)
                    
                    Text("Quickly reach consensus in your group by swiping through options")
                        .font(.system(size: 16))
                        .foregroundColor(Color.themeTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
                
                Button {
                    Task {
                        do {
                            try await authService.signInAnonymously()
                        } catch {
                            // Error is already handled in the service
                        }
                    }
                } label: {
                    Text("Continue Anonymously")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.themeAccent)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
                
                if let error = authService.authError {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.themeBackground)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService.shared)
}

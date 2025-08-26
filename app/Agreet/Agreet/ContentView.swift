//
//  ContentView.swift
//  Agreet
//
//  Created by Kevin on 25.08.25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
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
                        await authService.signInAnonymously()
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

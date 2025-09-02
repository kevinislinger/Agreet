import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section("Profile") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.themeAccent)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(.themeTextPrimary)
                            
                            if viewModel.isEditingUsername {
                                HStack {
                                    TextField("Enter username", text: $viewModel.editingUsername)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                    
                                    Button("Save") {
                                        Task {
                                            await viewModel.saveUsername()
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(viewModel.editingUsername.isEmpty)
                                    
                                    Button("Cancel") {
                                        viewModel.cancelUsernameEdit()
                                    }
                                    .buttonStyle(.bordered)
                                }
                            } else {
                                HStack {
                                    Text(viewModel.currentUsername)
                                        .foregroundColor(.themeTextSecondary)
                                    
                                    Spacer()
                                    
                                    Button("Edit") {
                                        viewModel.startUsernameEdit()
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Notifications Section
                Section("Notifications") {
                    HStack {
                        Image(systemName: "bell.fill")
                            .font(.title2)
                            .foregroundColor(.themeSecondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Push Notifications")
                                .font(.headline)
                                .foregroundColor(.themeTextPrimary)
                            
                            Text("Get notified when your group finds a match")
                                .font(.caption)
                                .foregroundColor(.themeTextSecondary)
                        }
                        
                        Spacer()
                        
                        // Status indicator
                        HStack(spacing: 8) {
                            Circle()
                                .fill(viewModel.pushNotificationsEnabled ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            
                            Text(viewModel.pushNotificationsEnabled ? "Enabled" : "Disabled")
                                .font(.caption)
                                .foregroundColor(viewModel.pushNotificationsEnabled ? .green : .red)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Settings button
                    Button(action: {
                        viewModel.openNotificationSettings()
                    }) {
                        HStack {
                            Image(systemName: "gear")
                                .foregroundColor(.themeSecondary)
                            
                            Text("Open iOS Settings")
                                .foregroundColor(.themeTextPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.themeTextSecondary)
                        }
                    }
                    .padding(.leading, 32)
                    
                    if !viewModel.pushNotificationsEnabled {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.themeSecondary)
                            
                            Text("Enable notifications in iOS Settings to get match alerts")
                                .font(.caption)
                                .foregroundColor(.themeTextSecondary)
                            
                            Spacer()
                        }
                        .padding(.leading, 32)
                    }
                }
                
                // App Information Section
                Section("App Information") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.title2)
                            .foregroundColor(.themeTertiary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Version")
                                .font(.headline)
                                .foregroundColor(.themeTextPrimary)
                            
                            Text(viewModel.appVersion)
                                .font(.caption)
                                .foregroundColor(.themeTextSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.themeTertiary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Member Since")
                                .font(.headline)
                                .foregroundColor(.themeTextPrimary)
                            
                            Text(viewModel.memberSinceText)
                                .font(.caption)
                                .foregroundColor(.themeTextSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                // Support Section
                Section("Support") {
                    Button(action: {
                        viewModel.showHelp()
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.themeSecondary)
                            
                            Text("Help & Support")
                                .foregroundColor(.themeTextPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.themeTextSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Button(action: {
                        viewModel.showPrivacyPolicy()
                    }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .font(.title2)
                                .foregroundColor(.themeSecondary)
                            
                            Text("Privacy Policy")
                                .foregroundColor(.themeTextPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.themeTextSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Account Section
                Section("Account") {
                    Button(action: {
                        Task {
                            await viewModel.signOut()
                        }
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title2)
                                .foregroundColor(.red)
                            
                            Text("Sign Out")
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Success", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.successMessage)
        }
        .onAppear {
            viewModel.loadUserData()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh notification preferences when app comes to foreground
            // This handles the case when user returns from iOS Settings
            // and ensures backend is synced with actual iOS permission state
            viewModel.refreshNotificationPreferences()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Also refresh when app becomes active to catch any permission changes
            // that might have happened while the app was in background
            viewModel.refreshNotificationPreferences()
        }
    }
}

#Preview {
    SettingsView()
}

import SwiftUI

struct JoinSessionView: View {
    @StateObject private var viewModel = JoinSessionViewModel()
    @Environment(\.presentationMode) private var presentationMode

    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.themeBackground.edgesIgnoringSafeArea(.all)
                
                // Main content
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color.themeAccent)
                        
                        Text("Join Session")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.themeTextPrimary)
                        
                        Text("Enter the invite code to join an existing session")
                            .font(.system(size: 16))
                            .foregroundColor(Color.themeTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    // Code input field
                    VStack(spacing: 8) {
                        Text("Invite Code")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.themeTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        TextField("Enter code", text: $viewModel.inviteCode)
                            .font(.system(size: 18, weight: .medium))
                            .padding()
                            .background(Color.themeCardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.themeAccent.opacity(0.5), lineWidth: 1)
                            )
                            .padding(.horizontal)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // Join button
                    Button {
                        Task {
                            if await viewModel.joinSession() {
                                // Dismiss this view and let the parent handle navigation
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    } label: {
                        Text("Join Session")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.themeAccent)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    // Cancel button
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 16))
                            .foregroundColor(Color.themeTextSecondary)
                    }
                    
                    Spacer()
                                }
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.themeAccent))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                        .edgesIgnoringSafeArea(.all)
                }
                

            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }

        }
    }
}

#Preview {
    JoinSessionView()
}

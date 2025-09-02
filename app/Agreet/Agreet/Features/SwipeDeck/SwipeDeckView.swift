import SwiftUI

struct SwipeDeckView: View {
    @StateObject private var viewModel = SwipeDeckViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingResults = false
    @State private var showingCloseSessionAlert = false
    @State private var showingCloseError = false
    @State private var closeErrorMessage = ""

    let session: Session
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.themeBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with session info
                    sessionHeader
                    
                    // Main swipe deck area
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.currentOptions.isEmpty {
                        emptyStateView
                    } else {
                        swipeDeckArea
                    }
                    
                    // Bottom toolbar
                    bottomToolbar
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.setSession(session)
        }
        .onChange(of: viewModel.matchFound) { _, matchFound in
            if matchFound {
                // When match is found, show results screen
                showingResults = true
            }
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .alert("Close Session", isPresented: $showingCloseSessionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Close Session", role: .destructive) {
                Task {
                    await closeSession()
                }
            }
        } message: {
            Text("Are you sure you want to close this session? This action cannot be undone and will end the session for all participants.")
        }
        .alert("Error Closing Session", isPresented: $showingCloseError) {
            Button("OK") { }
        } message: {
            Text(closeErrorMessage)
        }
        .fullScreenCover(isPresented: $showingResults) {
            if let matchedOption = viewModel.matchedOption {
                ResultsView(session: session, matchedOption: matchedOption)
                    .onDisappear {
                        // When Results screen is dismissed, also dismiss this SwipeDeckView
                        SessionService.shared.clearCurrentSession()
                        dismiss()
                    }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func closeSession() async {
        let success = await SessionService.shared.closeCurrentSession()
        if success {
            // Session was closed successfully, dismiss this view
            dismiss()
        } else {
            // Show error message
            if let error = SessionService.shared.error {
                closeErrorMessage = error.localizedDescription
                showingCloseError = true
            } else {
                closeErrorMessage = "Failed to close session. Please try again."
                showingCloseError = true
            }
        }
    }
    
    // MARK: - Components
    
    private var sessionHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.themeTextSecondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(session.category?.name ?? "Unknown Category")
                        .font(.headline)
                        .foregroundColor(.themeTextPrimary)
                    
                    Text("\(session.participantCount)/\(session.quorumN) participants")
                        .font(.caption)
                        .foregroundColor(.themeTextSecondary)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Close session button (only for creators)
                    if SessionService.shared.isCurrentUserCreator {
                        Button(action: {
                            showingCloseSessionAlert = true
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.themeDislikeColor)
                        }
                    }
                    
                    // Session info button
                    Button(action: {
                        // Show session info
                    }) {
                        Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundColor(.themeTextSecondary)
                    }
                }
            }
            .padding(.horizontal)
            
            // Progress indicator
            ProgressView(value: Double(viewModel.optionsRemaining), total: Double(viewModel.totalOptions))
                .progressViewStyle(LinearProgressViewStyle(tint: .themeAccent))
                .padding(.horizontal)
        }
        .padding(.top)
        .background(Color.themeCardBackground)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading options...")
                .font(.body)
                .foregroundColor(.themeTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    

    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.themeAccent)
            
            Text("All options reviewed!")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.themeTextPrimary)
            
            Text("Waiting for other participants to finish...")
                .font(.body)
                .foregroundColor(.themeTextSecondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Button("Leave Session") {
                    // Clear the current session from SessionService
                    SessionService.shared.clearCurrentSession()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.themeAccent)
                
                // Close session button (only for creators)
                if SessionService.shared.isCurrentUserCreator {
                    Button("Close Session") {
                        showingCloseSessionAlert = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.themeDislikeColor)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var swipeDeckArea: some View {
        ZStack {
            // Background cards (stacked effect)
            ForEach(Array(viewModel.currentOptions.enumerated().reversed()), id: \.element.id) { index, option in
                if index < 3 { // Only show top 3 cards for performance
                    SwipeCardView(
                        option: option,
                        isTopCard: index == 0,
                        onSwipe: { direction in
                            viewModel.handleSwipe(option: option, direction: direction)
                        }
                    )
                    .offset(y: CGFloat(index) * 4)
                    .scaleEffect(1.0 - CGFloat(index) * 0.05)
                    .zIndex(Double(viewModel.currentOptions.count - index))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }
    
    private var bottomToolbar: some View {
        HStack(spacing: 40) {
            // Dislike button
            Button(action: {
                if let currentOption = viewModel.currentOptions.first {
                    viewModel.handleSwipe(option: currentOption, direction: .left)
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.themeDislikeColor)
            }
            .disabled(viewModel.currentOptions.isEmpty)
            
            // Like button
            Button(action: {
                if let currentOption = viewModel.currentOptions.first {
                    viewModel.handleSwipe(option: currentOption, direction: .right)
                }
            }) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.themeLikeColor)
            }
            .disabled(viewModel.currentOptions.isEmpty)
        }
        .padding(.bottom, 40)
        .background(Color.themeCardBackground)
    }
}

// Preview removed - requires actual session data

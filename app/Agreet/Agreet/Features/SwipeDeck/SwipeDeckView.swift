import SwiftUI

struct SwipeDeckView: View {
    @StateObject private var viewModel = SwipeDeckViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingResults = false
    
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
                    } else if viewModel.matchFound {
                        matchFoundView
                    } else if viewModel.currentOptions.isEmpty {
                        emptyStateView
                    } else {
                        swipeDeckArea
                    }
                    
                    // Bottom toolbar (hidden when match is found)
                    if !viewModel.matchFound {
                        bottomToolbar
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.setSession(session)
        }
        .onChange(of: viewModel.matchFound) { _, matchFound in
            if matchFound {
                // Automatically show results after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showingResults = true
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .fullScreenCover(isPresented: $showingResults) {
            if let matchedOption = viewModel.matchedOption {
                ResultsView(session: session, matchedOption: matchedOption)
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
                    
                    if viewModel.matchFound {
                        Text("Match Found! 🎉")
                            .font(.caption)
                            .foregroundColor(.themeMatchColor)
                            .fontWeight(.semibold)
                    } else {
                        Text("\(session.participantCount)/\(session.quorumN) participants")
                            .font(.caption)
                            .foregroundColor(.themeTextSecondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    // Show session info
                }) {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundColor(.themeTextSecondary)
                }
            }
            .padding(.horizontal)
            
            // Progress indicator (hidden when match is found)
            if !viewModel.matchFound {
                ProgressView(value: Double(viewModel.optionsRemaining), total: Double(viewModel.totalOptions))
                    .progressViewStyle(LinearProgressViewStyle(tint: .themeAccent))
                    .padding(.horizontal)
            }
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
    
    private var matchFoundView: some View {
        VStack(spacing: 24) {
            // Success animation
            ZStack {
                Circle()
                    .fill(Color.themeMatchColor)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(1.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: viewModel.matchFound)
            
            Text("Match Found!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.themeTextPrimary)
            
            if let matchedOption = viewModel.matchedOption {
                VStack(spacing: 16) {
                    // Matched option card
                    VStack(spacing: 12) {
                        if let url = URL(string: matchedOption.imageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.themeSecondary.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.title)
                                            .foregroundColor(.themeTextSecondary)
                                    )
                            }
                            .frame(width: 200, height: 150)
                            .clipped()
                            .cornerRadius(12)
                        }
                        
                        Text(matchedOption.label)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.themeTextPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.themeCardBackground)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
            }
            
            Text("All participants agreed on this option!")
                .font(.body)
                .foregroundColor(.themeTextSecondary)
                .multilineTextAlignment(.center)
            
            Text("Opening results...")
                .font(.caption)
                .foregroundColor(.themeTextSecondary)
                .padding(.top, 8)
        }
        .padding()
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
            
            Button("Leave Session") {
                // Clear the current session from SessionService
                SessionService.shared.clearCurrentSession()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(.themeAccent)
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
                        disabled: viewModel.matchFound,
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
            .disabled(viewModel.currentOptions.isEmpty || viewModel.matchFound)
            
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
            .disabled(viewModel.currentOptions.isEmpty || viewModel.matchFound)
        }
        .padding(.bottom, 40)
        .background(Color.themeCardBackground)
    }
}

// Preview removed - requires actual session data

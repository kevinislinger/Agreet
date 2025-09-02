import SwiftUI

struct AsyncResultsView: View {
    let session: Session
    let matchedOptionId: UUID
    
    @State private var matchedOption: Option?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if let matchedOption = matchedOption {
                ResultsView(session: session, matchedOption: matchedOption)
            } else {
                errorView(message: "Could not load matched option")
            }
        }
        .onAppear {
            Task {
                await fetchMatchedOption()
            }
        }
    }
    
    private var loadingView: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                
                Text("Loading results...")
                    .font(.body)
                    .foregroundColor(.themeTextSecondary)
            }
        }
    }
    
    private func errorView(message: String) -> some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.themeTextSecondary)
                
                Text("Error")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.themeTextPrimary)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.themeTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    @MainActor
    private func fetchMatchedOption() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let option = try await NetworkService.shared.fetchOption(id: matchedOptionId)
            matchedOption = option
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

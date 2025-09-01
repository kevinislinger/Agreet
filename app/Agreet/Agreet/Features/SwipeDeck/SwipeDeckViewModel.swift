import Foundation
import SwiftUI
import Combine

@MainActor
class SwipeDeckViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var currentOptions: [Option] = []
    @Published private(set) var isLoading = false
    @Published private(set) var matchFound = false
    @Published private(set) var matchedOptionId: UUID?
    @Published var showingError = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var session: Session?
    private var allOptions: [Option] = []
    private var sessionService = SessionService.shared
    
    // MARK: - Computed Properties
    
    var totalOptions: Int {
        return allOptions.count
    }
    
    var optionsRemaining: Int {
        return currentOptions.count
    }
    
    // MARK: - Public Methods
    
    func setSession(_ session: Session) {
        self.session = session
        loadOptions()
    }
    
    func handleSwipe(option: Option, direction: SwipeDirection) {
        guard session != nil else { return }
        
        // Remove the swiped option from current options
        currentOptions.removeAll { $0.id == option.id }
        
        // Handle like action
        if direction == .right {
            Task {
                await likeOption(option)
            }
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: direction == .right ? .medium : .light)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Private Methods
    
    private func loadOptions() {
        guard let session = session else { return }
        
        isLoading = true
        
        Task {
            do {
                // Set the current session in the session service
                sessionService.setCurrentSession(session)
                
                // Wait a moment for the options to load
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                // Get the options from the session service
                allOptions = sessionService.sessionOptions
                currentOptions = allOptions
                
                isLoading = false
            } catch {
                self.errorMessage = "Failed to load options: \(error.localizedDescription)"
                self.showingError = true
                isLoading = false
            }
        }
    }
    
    private func likeOption(_ option: Option) async {
        let result = await sessionService.likeOption(optionId: option.id)
        
        if result.matchFound {
            matchFound = true
            matchedOptionId = result.matchedOptionId
            
            // Add success haptic feedback
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        }
    }
}

// MARK: - Supporting Types

enum SwipeDirection {
    case left  // Dislike
    case right // Like
}

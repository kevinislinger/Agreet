import Foundation
import SwiftUI

@MainActor
class ResultsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var isLoading = false
    @Published var showingError = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let sessionService = SessionService.shared
    
    // MARK: - Public Methods
    
    /// Refreshes the session data to get the latest information
    func refreshSession() async {
        isLoading = true
        
        await sessionService.refreshOpenSessions()
        await sessionService.refreshClosedSessions()
        isLoading = false
    }
    
    /// Clears the current session and returns to the main screen
    func clearSession() {
        sessionService.clearCurrentSession()
    }
}

// MARK: - Supporting Types

/// Represents the result of a session
struct SessionResult {
    let session: Session
    let matchedOption: Option?
    let participants: [SessionParticipant]
    let matchTime: Date?
    
    var isMatch: Bool {
        return matchedOption != nil
    }
    
    var participantCount: Int {
        return participants.count
    }
}

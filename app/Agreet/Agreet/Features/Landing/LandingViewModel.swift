import Foundation
import SwiftUI
import Combine

class LandingViewModel: ObservableObject {
    @Published var openSessions: [Session] = []
    @Published var closedSessions: [Session] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let sessionService = SessionService.shared
    
    init() {
        Task { @MainActor in
            await fetchSessions()
        }
    }
    
    @MainActor
    func fetchSessions() async {
        isLoading = true
        errorMessage = nil
        
        // Fetch open and closed sessions
        let openResult = await sessionService.refreshOpenSessions()
        let closedResult = await sessionService.refreshClosedSessions()
        
        if !openResult || !closedResult {
            if let error = sessionService.error {
                errorMessage = "Failed to fetch sessions: \(error.localizedDescription)"
            } else {
                errorMessage = "Failed to fetch sessions"
            }
        }
        
        // Get data from the session service
        self.openSessions = sessionService.openSessions
        self.closedSessions = sessionService.closedSessions
        
        isLoading = false
    }
    
    // Set a session as current in the SessionService
    func setCurrentSession(_ session: Session) {
        Task {
            await sessionService.setCurrentSession(session)
        }
    }
}
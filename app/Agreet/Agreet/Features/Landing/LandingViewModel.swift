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
    
    // Flag to prevent duplicate fetches
    private var initialFetchCompleted = false
    
    init() {
        // Don't fetch in init - let the view's onAppear handle it
    }
    
    // Task to track ongoing fetch operations
    private var fetchTask: Task<Void, Never>?
    
    @MainActor
    func fetchSessions() async {
        // For manually triggered refreshes (like pull-to-refresh), always fetch
        // For automatic fetches (like onAppear), only fetch if we haven't already
        let isManualRefresh = Task.isCancelled == false && isLoading == false
        
        if !isManualRefresh && initialFetchCompleted {
            // Skip duplicate automatic fetches
            return
        }
        
        // Cancel any ongoing fetch operation
        fetchTask?.cancel()
        
        // Create a new fetch task
        fetchTask = Task { @MainActor in
            isLoading = true
            errorMessage = nil
            
            // Authentication should already be complete since ContentView
            // only shows LandingView when auth is done
            
            // Fetch the sessions with error handling
            let openResult = await sessionService.refreshOpenSessions()
            let closedResult = await sessionService.refreshClosedSessions()
            
            // Only update UI if the task wasn't cancelled
            if !Task.isCancelled {
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
                initialFetchCompleted = true
            }
        }
    }
    
    // Set a session as current in the SessionService
    func setCurrentSession(_ session: Session) {
        Task {
            await sessionService.setCurrentSession(session)
        }
    }
    

}
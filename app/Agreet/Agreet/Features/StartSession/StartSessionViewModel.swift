import Foundation
import SwiftUI
import Combine

class StartSessionViewModel: ObservableObject {
    // Data for UI
    @Published var categories: [Category] = []
    @Published var selectedCategoryId: UUID?
    @Published var quorum: Int = 2
    
    // States
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var createdSession: Session?
    @Published var showShareSheet = false
    
    // Services
    private let sessionService = SessionService.shared
    private let networkService = NetworkService.shared
    
    // Constants
    let minQuorum = 2
    let maxQuorum = 5
    
    init() {
        // Load categories when initialized
        Task {
            await loadCategories()
        }
    }
    
    @MainActor
    func loadCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            categories = try await networkService.fetchCategories()
            
            // Auto-select the first category if available
            if let firstCategory = categories.first {
                selectedCategoryId = firstCategory.id
            }
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func createSession() async -> Bool {
        guard let categoryId = selectedCategoryId else {
            errorMessage = "Please select a category"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await networkService.createSession(categoryId: categoryId, quorum: quorum)
            createdSession = session
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = "Failed to create session: \(error.localizedDescription)"
            return false
        }
    }
    
    var inviteCode: String {
        createdSession?.inviteCode ?? ""
    }
    
    var inviteMessage: String {
        "Join my Agreet session with code: \(inviteCode)"
    }
}

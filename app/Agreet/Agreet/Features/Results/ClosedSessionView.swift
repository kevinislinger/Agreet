import SwiftUI

struct ClosedSessionView: View {
    let session: Session
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // No match card
                        noMatchCard
                        

                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Session Results")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.themeTextPrimary)
                
                Text(session.category?.name ?? "Unknown Category")
                    .font(.subheadline)
                    .foregroundColor(.themeTextSecondary)
            }
            
            // Status indicator
            HStack(spacing: 8) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.themeTextSecondary)
                
                Text("Session Closed")
                    .font(.headline)
                    .foregroundColor(.themeTextSecondary)
                    .fontWeight(.semibold)
            }
        }
    }
    
    private var noMatchCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.themeTextSecondary)
            
            Text("No Match Found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.themeTextPrimary)
            
            Text("The session was closed without finding a match. Participants may not have agreed on any option.")
                .font(.body)
                .foregroundColor(.themeTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(Color.themeCardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    

}

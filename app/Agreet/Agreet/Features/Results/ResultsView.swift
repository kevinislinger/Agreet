import SwiftUI

struct ResultsView: View {
    let session: Session
    let matchedOption: Option?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.themeBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Matched option card
                        if let matchedOption = matchedOption {
                            matchedOptionCard(matchedOption)
                        } else {
                            noMatchCard
                        }
                        

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
            
            // Success indicator
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.themeMatchColor)
                
                Text("Session Completed")
                    .font(.headline)
                    .foregroundColor(.themeMatchColor)
                    .fontWeight(.semibold)
            }
        }
    }
    
    private func matchedOptionCard(_ option: Option) -> some View {
        VStack(spacing: 16) {
            Text("🎉 Match Found! 🎉")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.themeTextPrimary)
            
            VStack(spacing: 16) {
                // Option image
                if let url = URL(string: option.imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.themeSecondary.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.themeTextSecondary)
                            )
                    }
                    .frame(width: 280, height: 200)
                    .clipped()
                    .cornerRadius(16)
                }
                
                // Option label
                Text(option.label)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.themeTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("All \(session.quorumN) participants agreed on this option!")
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
    
    private var noMatchCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.themeTextSecondary)
            
            Text("No Match Found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.themeTextPrimary)
            
            Text("The session was closed without finding a match.")
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

#Preview {
    ResultsView(
        session: Session(
            id: UUID(),
            creatorId: UUID(),
            categoryId: UUID(),
            quorumN: 3,
            status: "matched",
            matchedOptionId: UUID(),
            inviteCode: "ABC123",
            createdAt: Date(),
            participants: [],
            matchedOption: Option(
                id: UUID(),
                categoryId: UUID(),
                label: "Pizza Margherita",
                imageUrl: "https://example.com/pizza.jpg"
            ),
            category: Category(id: UUID(), name: "Food", iconUrl: nil)
        ),
        matchedOption: Option(
            id: UUID(),
            categoryId: UUID(),
            label: "Pizza Margherita",
            imageUrl: "https://example.com/pizza.jpg"
        )
    )
}

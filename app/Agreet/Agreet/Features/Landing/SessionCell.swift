import SwiftUI

struct SessionCell: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: 16) {
            // Category icon or placeholder
            ZStack {
                Circle()
                    .fill(Color.themeCardBackground)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                Text(categoryInitial)
                    .font(Font.system(size: 20, weight: .bold))
                    .foregroundColor(Color.themeAccent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(getCategoryName())
                    .font(Font.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.themeTextPrimary)
                
                HStack(spacing: 12) {
                    // Participant count indicator
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(Font.system(size: 12))
                            .foregroundColor(Color.themeTextSecondary)
                        
                        Text("\(session.participants?.count ?? 0)/\(session.quorumN)")
                            .font(Font.system(size: 12))
                            .foregroundColor(Color.themeTextSecondary)
                    }
                    
                    // Updated time indicator
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(Font.system(size: 12))
                            .foregroundColor(Color.themeTextSecondary)
                        
                        Text(formattedUpdatedTime)
                            .font(Font.system(size: 12))
                            .foregroundColor(Color.themeTextSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Status indicator or action button
            if session.status == "matched" {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.themeTertiary)
                    .font(Font.system(size: 20))
            } else if session.status == "closed" {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color.red)
                    .font(Font.system(size: 20))
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.themeAccent)
                    .font(Font.system(size: 20))
            }
        }
        .padding(16)
        .background(Color.themeCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // Helper computed properties
    private var categoryInitial: String {
        let name = getCategoryName()
        return String(name.prefix(1))
    }
    
    private func getCategoryName() -> String {
        // Get the category name from the relationship
        if let category = session.category {
            return category.name
        }
        
        // Fallback to looking up by categoryId if the relationship is missing
        return "Category"
    }
    
    private var formattedUpdatedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: session.createdAt, relativeTo: Date())
    }
}

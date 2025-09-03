import SwiftUI

struct SessionCell: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: 16) {
            // Category icon with improved styling
            ZStack {
                Circle()
                    .fill(Color.themeAccent.opacity(0.1))
                    .frame(width: 52, height: 52)
                
                Text(categoryInitial)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.themeAccent)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(getCategoryName())
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.themeTextPrimary)
                
                HStack(spacing: 16) {
                    // Participant count indicator
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.themeTextSecondary)
                        
                        Text("\(session.participants?.count ?? 0)/\(session.quorumN)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.themeTextSecondary)
                    }
                    
                    // Updated time indicator
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.themeTextSecondary)
                        
                        Text(formattedUpdatedTime)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.themeTextSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Status indicator with improved styling
            if session.status == "matched" {
                ZStack {
                    Circle()
                        .fill(Color.themeSecondary.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.themeSecondary)
                        .font(.system(size: 18))
                }
            } else if session.status == "closed" {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.red)
                        .font(.system(size: 18))
                }
            } else {
                ZStack {
                    Circle()
                        .fill(Color.themeAccent.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.themeAccent)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .padding(20)
        .background(Color.themeCardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.themeCardBackground.opacity(0.8), lineWidth: 1)
        )
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

import SwiftUI

extension Color {
    // App theme colors
    static let accentColor = Color("AccentColor")
    static let secondaryColor = Color("SecondaryColor")
    static let tertiaryColor = Color("TertiaryColor")
    static let backgroundColor = Color("BackgroundColor")
    
    // UI element colors
    static let cardBackground = Color("CardBackground")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    
    // Semantic colors for specific use cases
    static let likeColor = tertiaryColor
    static let dislikeColor = Color.red
    static let matchColor = Color.yellow.opacity(0.8)
    static let sessionCardBackground = cardBackground
    
    // Helper to get color with opacity
    func withOpacity(_ opacity: Double) -> Color {
        return self.opacity(opacity)
    }
}

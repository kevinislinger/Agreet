import SwiftUI

extension Color {
    // Semantic colors for specific use cases
    static let themeAccent = Color("AccentColor")
    static let themeSecondary = Color("AppSecondaryColor")
    static let themeTertiary = Color("AppTertiaryColor")
    static let themeBackground = Color("BackgroundColor")
    
    // UI element colors
    static let themeCardBackground = Color("CardBackground")
    static let themeTextPrimary = Color("TextPrimary")
    static let themeTextSecondary = Color("TextSecondary")
    
    // Functional colors
    static let themeLikeColor = themeTertiary
    static let themeDislikeColor = Color.red
    static let themeMatchColor = Color.yellow.opacity(0.8)
    static let themeSessionCardBackground = themeCardBackground
    
    // Helper to get color with opacity
    func withOpacity(_ opacity: Double) -> Color {
        return self.opacity(opacity)
    }
}

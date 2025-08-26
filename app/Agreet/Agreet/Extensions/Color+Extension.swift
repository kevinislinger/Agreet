import SwiftUI

extension Color {
    // App theme colors
    static let appAccent = Color("AccentColor")
    static let appSecondary = Color("AppSecondaryColor")
    static let appTertiary = Color("AppTertiaryColor")
    static let appBackground = Color("BackgroundColor")
    
    // UI element colors
    static let appCardBackground = Color("CardBackground")
    static let appTextPrimary = Color("TextPrimary")
    static let appTextSecondary = Color("TextSecondary")
    
    // Semantic colors for specific use cases
    static let appLikeColor = appTertiary
    static let appDislikeColor = Color.red
    static let appMatchColor = Color.yellow.opacity(0.8)
    static let appSessionCardBackground = appCardBackground
    
    // Helper to get color with opacity
    func withOpacity(_ opacity: Double) -> Color {
        return self.opacity(opacity)
    }
}

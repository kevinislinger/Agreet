import SwiftUI

extension Text {
    func primaryTextStyle() -> some View {
        self
            .foregroundColor(.textPrimary)
    }
    
    func secondaryTextStyle() -> some View {
        self
            .foregroundColor(.textSecondary)
    }
    
    func titleStyle() -> some View {
        self
            .font(.title2)
            .foregroundColor(.textPrimary)
            .fontWeight(.bold)
    }
    
    func headlineStyle() -> some View {
        self
            .font(.title3)
            .foregroundColor(.textPrimary)
            .fontWeight(.semibold)
    }
    
    func bodyStyle() -> some View {
        self
            .font(.bodyMedium)
            .foregroundColor(.textPrimary)
    }
    
    func captionStyle() -> some View {
        self
            .font(.caption)
            .foregroundColor(.textSecondary)
    }
    
    func buttonTextStyle() -> some View {
        self
            .font(.buttonMedium)
            .foregroundColor(.white)
    }
    
    // Alternative button style using accent color
    func accentButtonTextStyle() -> some View {
        self
            .font(.buttonMedium)
            .foregroundColor(.accentColor)
    }
}

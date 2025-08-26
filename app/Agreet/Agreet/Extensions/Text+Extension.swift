import SwiftUI

extension Text {
    func primaryTextStyle() -> some View {
        self
            .foregroundColor(Color.themeTextPrimary)
    }
    
    func secondaryTextStyle() -> some View {
        self
            .foregroundColor(Color.themeTextSecondary)
    }
    
    func titleStyle() -> some View {
        self
            .font(Font.system(size: 22, weight: .bold))
            .foregroundColor(Color.themeTextPrimary)
    }
    
    func headlineStyle() -> some View {
        self
            .font(Font.system(size: 20, weight: .semibold))
            .foregroundColor(Color.themeTextPrimary)
    }
    
    func bodyStyle() -> some View {
        self
            .font(Font.system(size: 15))
            .foregroundColor(Color.themeTextPrimary)
    }
    
    func captionStyle() -> some View {
        self
            .font(Font.system(size: 12))
            .foregroundColor(Color.themeTextSecondary)
    }
    
    func buttonTextStyle() -> some View {
        self
            .font(Font.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
    }
    
    // Alternative button style using accent color
    func accentButtonTextStyle() -> some View {
        self
            .font(Font.system(size: 15, weight: .semibold))
            .foregroundColor(Color.themeAccent)
    }
}

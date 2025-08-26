import SwiftUI

extension Text {
    func primaryTextStyle() -> some View {
        self
            .foregroundColor(Color.appTextPrimary)
    }
    
    func secondaryTextStyle() -> some View {
        self
            .foregroundColor(Color.appTextSecondary)
    }
    
    func titleStyle() -> some View {
        self
            .font(Font.system(size: 22, weight: .bold))
            .foregroundColor(Color.appTextPrimary)
    }
    
    func headlineStyle() -> some View {
        self
            .font(Font.system(size: 20, weight: .semibold))
            .foregroundColor(Color.appTextPrimary)
    }
    
    func bodyStyle() -> some View {
        self
            .font(Font.system(size: 15))
            .foregroundColor(Color.appTextPrimary)
    }
    
    func captionStyle() -> some View {
        self
            .font(Font.system(size: 12))
            .foregroundColor(Color.appTextSecondary)
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
            .foregroundColor(Color.appAccent)
    }
}

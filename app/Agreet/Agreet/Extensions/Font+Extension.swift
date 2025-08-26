import SwiftUI

extension Font {
    // Heading styles
    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title1 = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 22, weight: .bold)
    static let title3 = Font.system(size: 20, weight: .semibold)
    
    // Body styles
    static let bodyLarge = Font.system(size: 17)
    static let bodyMedium = Font.system(size: 15)
    static let bodySmall = Font.system(size: 13)
    
    // Emphasized text
    static let emphasizedLarge = Font.system(size: 17, weight: .semibold)
    static let emphasizedMedium = Font.system(size: 15, weight: .semibold)
    static let emphasizedSmall = Font.system(size: 13, weight: .semibold)
    
    // Button text
    static let buttonLarge = Font.system(size: 17, weight: .semibold)
    static let buttonMedium = Font.system(size: 15, weight: .semibold)
    static let buttonSmall = Font.system(size: 13, weight: .medium)
    
    // Caption text
    static let caption = Font.system(size: 12)
    static let captionBold = Font.system(size: 12, weight: .bold)
}

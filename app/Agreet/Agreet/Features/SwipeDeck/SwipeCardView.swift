import SwiftUI

struct SwipeCardView: View {
    let option: Option
    let isTopCard: Bool
    let onSwipe: (SwipeDirection) -> Void
    
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    private let cardWidth: CGFloat = UIScreen.main.bounds.width - 40
    private let cardHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.themeCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // Main image area with text overlay
            ZStack {
                // Placeholder background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.themeSecondary.opacity(0.3))
                
                // Option image
                if let imagePath = option.imagePath, !imagePath.isEmpty {
                    AsyncImageView(imagePath: imagePath)
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                        .cornerRadius(20)
                } else {
                    // Fallback when no image path is available
                    VStack(spacing: 16) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.themeTextSecondary)
                        
                        Text(option.label)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.themeTextSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 20)
                    }
                }
                
                // Text overlay at bottom
                VStack {
                    Spacer()
                    
                    // Full-width gradient background at bottom
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    .overlay(
                        // Text on top of the gradient
                        Text(option.label)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 20)
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    )
                }
                
                // Like/Dislike overlay indicators
                HStack {
                    // Dislike indicator (left side)
                    VStack {
                        Spacer()
                        HStack {
                            Text("NOPE")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.themeDislikeColor)
                                )
                                .rotationEffect(.degrees(-15))
                                .opacity(offset.width < 0 ? Double(-offset.width / 50) : 0)
                            
                            Spacer()
                        }
                        .padding(.leading, 20)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Like indicator (right side)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("LIKE")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.themeLikeColor)
                                )
                                .rotationEffect(.degrees(15))
                                .opacity(offset.width > 0 ? Double(offset.width / 50) : 0)
                        }
                        .padding(.trailing, 20)
                        Spacer()
                    }
                }
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipped()
        }
        .frame(width: cardWidth, height: cardHeight)
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if isTopCard {
                        offset = gesture.translation
                        rotation = Double(gesture.translation.width / 20)
                        scale = 1.0 - abs(gesture.translation.width) / 1000
                    }
                }
                .onEnded { gesture in
                    if isTopCard {
                        handleSwipeEnd(gesture)
                    }
                }
        )
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.8), value: offset)
    }
    
    private func handleSwipeEnd(_ gesture: DragGesture.Value) {
        let swipeThreshold: CGFloat = 100
        
        if abs(gesture.translation.width) > swipeThreshold {
            // Swipe was significant enough to trigger action
            let direction: SwipeDirection = gesture.translation.width > 0 ? .right : .left
            
            // Animate card off screen
            withAnimation(.easeOut(duration: 0.3)) {
                offset = CGSize(
                    width: gesture.translation.width > 0 ? cardWidth * 2 : -cardWidth * 2,
                    height: gesture.translation.height
                )
                rotation = gesture.translation.width > 0 ? 20 : -20
                scale = 0.8
            }
            
            // Call the swipe handler after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwipe(direction)
            }
        } else {
            // Swipe wasn't significant, reset to center
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8)) {
                offset = .zero
                rotation = 0
                scale = 1.0
            }
        }
    }
}

#Preview {
    SwipeCardView(
        option: Option(
            id: UUID(),
            categoryId: UUID(),
            label: "Pizza Margherita",
            imagePath: "restaurants/italian.jpg"
        ),
        isTopCard: true,
        onSwipe: { _ in }
    )
    .padding()
}

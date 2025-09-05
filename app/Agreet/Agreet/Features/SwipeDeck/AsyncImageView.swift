import SwiftUI

struct AsyncImageView: View {
    let imagePath: String
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var hasError = false
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if hasError {
                // Error state
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.themeTextSecondary)
                    
                    Text("Image Error")
                        .font(.caption)
                        .foregroundColor(.themeTextSecondary)
                }
            } else {
                // Loading state
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .themeTextSecondary))
                    
                    Text("Loading...")
                        .font(.caption)
                        .foregroundColor(.themeTextSecondary)
                }
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        isLoading = true
        hasError = false
        
        Task {
            let loadedImage = await ImageService.shared.loadImage(from: imagePath)
            await MainActor.run {
                if let loadedImage = loadedImage {
                    self.image = loadedImage
                } else {
                    self.hasError = true
                }
                self.isLoading = false
            }
        }
    }
}

#Preview {
    AsyncImageView(imagePath: "restaurants/italian.jpg")
        .frame(width: 300, height: 200)
        .background(Color.gray.opacity(0.2))
}

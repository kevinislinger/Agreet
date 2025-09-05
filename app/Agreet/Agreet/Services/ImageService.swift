import Foundation
import SwiftUI
import Supabase

class ImageService: ObservableObject {
    static let shared = ImageService()
    private let supabase = SupabaseService.shared.supabase
    
    private init() {}
    
    func loadImage(from path: String) async -> UIImage? {
        do {
            let data = try await supabase.storage
                .from("option-images")
                .download(path: path)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}

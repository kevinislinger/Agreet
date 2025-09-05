import Foundation

struct Option: Codable, Identifiable, Equatable {
    let id: UUID
    let categoryId: UUID
    let label: String
    let imagePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case label
        case imagePath = "image_path"
    }
}

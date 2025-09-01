import Foundation

enum SessionStatus: String, Codable {
    case open
    case matched
    case closed
}

struct Session: Codable, Identifiable, Equatable {
    let id: UUID
    let creatorId: UUID
    let categoryId: UUID
    let quorumN: Int
    var status: String // Using String instead of enum for more flexible decoding
    var matchedOptionId: UUID?
    let inviteCode: String
    let createdAt: Date
    var participants: [SessionParticipant]?
    var matchedOption: Option?
    var category: Category?
    
    enum CodingKeys: String, CodingKey {
        case id
        case creatorId = "creator_id"
        case categoryId = "category_id"
        case quorumN = "quorum_n"
        case status
        case matchedOptionId = "matched_option_id"
        case inviteCode = "invite_code"
        case createdAt = "created_at"
        case participants = "session_participants"
        case matchedOption = "options" // For joined queries that include the matched option
        case category = "categories" // For joined queries that include the category
    }
    
    // Custom decoder initialization to handle date format from Supabase
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        creatorId = try container.decode(UUID.self, forKey: .creatorId)
        categoryId = try container.decode(UUID.self, forKey: .categoryId)
        quorumN = try container.decode(Int.self, forKey: .quorumN)
        status = try container.decode(String.self, forKey: .status)
        matchedOptionId = try container.decodeIfPresent(UUID.self, forKey: .matchedOptionId)
        inviteCode = try container.decode(String.self, forKey: .inviteCode)
        
        // Handle date
        if let dateString = try? container.decode(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = formatter.date(from: dateString) {
                createdAt = date
            } else {
                let simpleFormatter = ISO8601DateFormatter()
                if let date = simpleFormatter.date(from: dateString) {
                    createdAt = date
                } else {
                    createdAt = Date()
                }
            }
        } else {
            createdAt = Date()
        }
        
        // Decode relationships if present
        participants = try container.decodeIfPresent([SessionParticipant].self, forKey: .participants)
        matchedOption = try container.decodeIfPresent(Option.self, forKey: .matchedOption)
        category = try container.decodeIfPresent(Category.self, forKey: .category)
    }
    
    // Convenience initializer for manual creation (needed for joining session by invite code)
    init(id: UUID, creatorId: UUID, categoryId: UUID, quorumN: Int, status: String, matchedOptionId: UUID?, inviteCode: String, createdAt: Date, participants: [SessionParticipant]?, matchedOption: Option?, category: Category?) {
        self.id = id
        self.creatorId = creatorId
        self.categoryId = categoryId
        self.quorumN = quorumN
        self.status = status
        self.matchedOptionId = matchedOptionId
        self.inviteCode = inviteCode
        self.createdAt = createdAt
        self.participants = participants
        self.matchedOption = matchedOption
        self.category = category
    }
    
    // MARK: - Computed Properties
    
    var participantCount: Int {
        return participants?.count ?? 0
    }
}

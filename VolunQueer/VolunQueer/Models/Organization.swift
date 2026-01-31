import Foundation

/// Organization hosting events.
struct Organization: Identifiable, Codable, Hashable, FirestoreDocument {
    var id: String
    var name: String
    var mission: String?
    var website: String?
    var location: LocationInfo?
    var contact: ContactInfo?
    var verified: Bool
    var ownerUid: String
    var createdAt: Date
    var updatedAt: Date
}

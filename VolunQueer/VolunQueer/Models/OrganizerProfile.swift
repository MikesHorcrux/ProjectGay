import Foundation

/// Organizer-specific profile details.
struct OrganizerProfile: Codable, Hashable {
    var orgIds: [String]
    var contactRole: String?
    var verified: Bool
}

// MARK: - Organizations

import Foundation

/// Role assignment within an event and its slot counts.
struct EventRole: Identifiable, Codable, Hashable, FirestoreDocument {
    var id: String
    var title: String
    var description: String?
    var slotsTotal: Int
    var slotsFilled: Int
    var skillsRequired: [String]
    var checkInRequired: Bool
    var minAge: Int?
}

// MARK: - RSVPs and Attendance

import Foundation

/// Check-in/out and hours for an event attendance record.
struct Attendance: Identifiable, Codable, Hashable, FirestoreDocument {
    var id: String
    var userId: String
    var checkedInAt: Date?
    var checkedOutAt: Date?
    var hours: Double?
    var verifiedBy: String?
    var notes: String?
}

// MARK: - Communication

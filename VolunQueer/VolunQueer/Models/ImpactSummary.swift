import Foundation

/// Cached impact totals for a user.
struct ImpactSummary: Codable, Hashable {
    var totalHours: Double
    var eventsAttended: Int
    var lastEventAt: Date?
}

import Foundation

/// Volunteer availability by weekday and time windows.
struct Availability: Codable, Hashable {
    var timezone: String
    var weekly: [WeekdayAvailability]
}

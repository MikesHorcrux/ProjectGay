import Foundation

/// Availability windows for a specific weekday.
struct WeekdayAvailability: Codable, Hashable {
    var weekday: Weekday
    var windows: [TimeWindow]
}

import Foundation

/// Time window in minutes from midnight.
struct TimeWindow: Codable, Hashable {
    var startMinutes: Int
    var endMinutes: Int
}

//
//  WeekdayAvailability.swift
//  VolunQueer
//

import Foundation

struct WeekdayAvailability: Codable, Hashable {
    var weekday: Weekday
    var windows: [TimeWindow]
}

//
//  Availability.swift
//  VolunQueer
//

import Foundation

struct Availability: Codable, Hashable {
    var timezone: String
    var weekly: [WeekdayAvailability]
}

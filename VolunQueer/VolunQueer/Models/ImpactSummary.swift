//
//  ImpactSummary.swift
//  VolunQueer
//

import Foundation

struct ImpactSummary: Codable, Hashable {
    var totalHours: Double
    var eventsAttended: Int
    var lastEventAt: Date?
}

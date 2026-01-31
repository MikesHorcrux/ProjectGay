//
//  Event.swift
//  VolunQueer
//

import Foundation

struct Event: Identifiable, Codable, Hashable, FirestoreDocument {
    var id: String
    var orgId: String
    var title: String
    var description: String?
    var startsAt: Date
    var endsAt: Date
    var timezone: String
    var location: LocationInfo
    var accessibility: AccessibilityInfo?
    var tags: [String]
    var rsvpCap: Int?
    var status: EventStatus
    var contact: EventContact?
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date
}

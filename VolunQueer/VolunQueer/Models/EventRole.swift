//
//  EventRole.swift
//  VolunQueer
//

import Foundation

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

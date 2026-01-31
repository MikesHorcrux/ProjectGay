//
//  VolunteerProfile.swift
//  VolunQueer
//

import Foundation

struct VolunteerProfile: Codable, Hashable {
    var interests: [String]
    var skills: [String]
    var availability: Availability?
    var accessibilityNeeds: [String]?
    var location: GeoLocation?
    var bio: String?
    var experienceNotes: String?
}

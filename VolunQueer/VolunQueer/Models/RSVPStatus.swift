//
//  RSVPStatus.swift
//  VolunQueer
//

import Foundation

enum RSVPStatus: String, Codable, Hashable {
    case rsvp
    case waitlisted
    case cancelled
    case noShow
}

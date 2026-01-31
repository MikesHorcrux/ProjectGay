//
//  OrganizerProfile.swift
//  VolunQueer
//

import Foundation

struct OrganizerProfile: Codable, Hashable {
    var orgIds: [String]
    var contactRole: String?
    var verified: Bool
}

// MARK: - Organizations

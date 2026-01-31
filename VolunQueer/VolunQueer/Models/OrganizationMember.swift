//
//  OrganizationMember.swift
//  VolunQueer
//

import Foundation

struct OrganizationMember: Identifiable, Codable, Hashable, FirestoreDocument {
    var id: String
    var userId: String
    var role: OrganizationRole
    var status: MembershipStatus
    var joinedAt: Date?
    var invitedAt: Date?
}

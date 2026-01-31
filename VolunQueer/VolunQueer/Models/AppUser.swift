//
//  AppUser.swift
//  VolunQueer
//

import Foundation

struct AppUser: Identifiable, Codable, Hashable, FirestoreDocument {
    var id: String
    var displayName: String
    var pronouns: String?
    var photoURL: String?
    var roles: [UserRole]
    var status: AccountStatus
    var visibility: UserVisibility
    var contact: ContactInfo?
    var volunteerProfile: VolunteerProfile?
    var organizerProfile: OrganizerProfile?
    var impactSummary: ImpactSummary?
    var createdAt: Date
    var updatedAt: Date
}

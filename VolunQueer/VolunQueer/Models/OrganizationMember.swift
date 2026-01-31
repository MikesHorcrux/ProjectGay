import Foundation

/// Membership record linking a user to an organization.
struct OrganizationMember: Identifiable, Codable, Hashable, FirestoreDocument {
    var id: String
    var userId: String
    var role: OrganizationRole
    var status: MembershipStatus
    var joinedAt: Date?
    var invitedAt: Date?
}

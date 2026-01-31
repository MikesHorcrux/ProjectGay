import Foundation

/// Membership state for an organization member.
enum MembershipStatus: String, Codable, Hashable {
    case active
    case invited
    case removed
}

// MARK: - Events

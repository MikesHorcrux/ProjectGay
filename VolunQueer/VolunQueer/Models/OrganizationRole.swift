import Foundation

/// Role of a member within an organization.
enum OrganizationRole: String, Codable, Hashable {
    case admin
    case staff
    case viewer
}

import Foundation

/// Private contact details for a user or organization.
struct ContactInfo: Codable, Hashable {
    var email: String?
    var phone: String?
    var preferredChannel: ContactChannel?
}

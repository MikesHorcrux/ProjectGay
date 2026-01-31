import Foundation

/// Preferred contact channel for a user.
enum ContactChannel: String, Codable, Hashable {
    case email
    case sms
    case push
}

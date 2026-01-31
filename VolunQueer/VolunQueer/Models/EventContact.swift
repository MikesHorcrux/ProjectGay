import Foundation

/// Public event contact information.
struct EventContact: Codable, Hashable {
    var name: String?
    var email: String?
    var phone: String?
}

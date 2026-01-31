import Foundation

/// Structured location details.
struct LocationInfo: Codable, Hashable {
    var name: String?
    var address: String?
    var city: String?
    var region: String?
    var postalCode: String?
    var country: String?
    var geo: GeoLocation?
}

import Foundation

/// Flags that control what profile fields are visible to organizers.
struct UserVisibility: Codable, Hashable {
    var shareEmail: Bool
    var sharePhone: Bool
    var sharePronouns: Bool
    var shareAccessibility: Bool
}

import Foundation

/// Single message within a thread.
struct Message: Identifiable, Codable, Hashable, FirestoreDocument {
    var id: String
    var threadId: String
    var senderUid: String
    var body: String
    var sentAt: Date
}

//
//  Message.swift
//  VolunQueer
//

import Foundation

struct Message: Identifiable, Codable, Hashable, FirestoreDocument {
    var id: String
    var threadId: String
    var senderUid: String
    var body: String
    var sentAt: Date
}

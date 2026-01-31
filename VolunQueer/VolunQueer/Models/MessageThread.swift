//
//  MessageThread.swift
//  VolunQueer
//

import Foundation

struct MessageThread: Identifiable, Codable, Hashable, FirestoreDocument {
    var id: String
    var eventId: String?
    var orgId: String?
    var participantUids: [String]
    var createdAt: Date
    var lastMessageAt: Date?
}

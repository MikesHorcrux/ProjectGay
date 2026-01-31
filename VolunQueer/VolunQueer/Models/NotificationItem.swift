//
//  NotificationItem.swift
//  VolunQueer
//

import Foundation

struct NotificationItem: Identifiable, Codable, Hashable, FirestoreDocument {
    var id: String
    var type: NotificationType
    var title: String
    var body: String
    var deepLink: String?
    var createdAt: Date
    var readAt: Date?
}

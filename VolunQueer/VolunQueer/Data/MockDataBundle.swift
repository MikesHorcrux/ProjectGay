//
//  MockDataBundle.swift
//  VolunQueer
//

import Foundation

struct MockDataBundle {
    let users: [AppUser]
    let organizations: [Organization]
    let membersByOrg: [String: [OrganizationMember]]
    let events: [Event]
    let rolesByEvent: [String: [EventRole]]
    let rsvpsByEvent: [String: [RSVP]]
    let attendanceByEvent: [String: [Attendance]]
    let messageThreads: [MessageThread]
    let messagesByThread: [String: [Message]]
    let notificationsByUser: [String: [NotificationItem]]
}

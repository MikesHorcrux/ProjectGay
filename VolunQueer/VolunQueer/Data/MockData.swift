//
//  MockData.swift
//  VolunQueer
//
//  Seed data for local development and previews.
//

import Foundation

enum MockData {
    static let bundle: MockDataBundle = {
        let now = Date()
        let nextFriday = Calendar.current.date(byAdding: .day, value: 5, to: now) ?? now
        let nextSaturday = Calendar.current.date(byAdding: .day, value: 6, to: now) ?? now
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now

        let visibility = UserVisibility(
            shareEmail: false,
            sharePhone: false,
            sharePronouns: true,
            shareAccessibility: true
        )

        let volunteerProfile = VolunteerProfile(
            interests: ["community", "mutual-aid"],
            skills: ["setup", "hospitality"],
            availability: Availability(
                timezone: "America/Chicago",
                weekly: [
                    WeekdayAvailability(
                        weekday: .saturday,
                        windows: [TimeWindow(startMinutes: 600, endMinutes: 1020)]
                    ),
                    WeekdayAvailability(
                        weekday: .sunday,
                        windows: [TimeWindow(startMinutes: 540, endMinutes: 900)]
                    )
                ]
            ),
            accessibilityNeeds: ["step-free"],
            location: GeoLocation(latitude: 41.8781, longitude: -87.6298),
            bio: "New in town and excited to help.",
            experienceNotes: "Previous volunteer at local pantry."
        )

        let organizerProfile = OrganizerProfile(
            orgIds: ["org-rainbow-center"],
            contactRole: "Volunteer Coordinator",
            verified: true
        )

        let users: [AppUser] = [
            AppUser(
                id: "user-alex",
                displayName: "Alex Rivera",
                pronouns: "they/them",
                photoURL: nil,
                roles: [.volunteer],
                status: .active,
                visibility: visibility,
                contact: ContactInfo(email: "alex@example.com", phone: nil, preferredChannel: .email),
                volunteerProfile: volunteerProfile,
                organizerProfile: nil,
                impactSummary: ImpactSummary(totalHours: 6.5, eventsAttended: 2, lastEventAt: lastWeek),
                createdAt: lastWeek,
                updatedAt: now
            ),
            AppUser(
                id: "user-jules",
                displayName: "Jules Kim",
                pronouns: "she/her",
                photoURL: nil,
                roles: [.organizer],
                status: .active,
                visibility: visibility,
                contact: ContactInfo(email: "jules@example.com", phone: "555-111-2222", preferredChannel: .email),
                volunteerProfile: nil,
                organizerProfile: organizerProfile,
                impactSummary: ImpactSummary(totalHours: 0, eventsAttended: 0, lastEventAt: nil),
                createdAt: lastWeek,
                updatedAt: now
            )
        ]

        let organizations: [Organization] = [
            Organization(
                id: "org-rainbow-center",
                name: "Rainbow Community Center",
                mission: "Create welcoming third spaces for LGBTQ+ neighbors.",
                website: "https://rainbow.example.org",
                location: LocationInfo(
                    name: "Rainbow Center",
                    address: "124 Community Way",
                    city: "Chicago",
                    region: "IL",
                    postalCode: "60601",
                    country: "US",
                    geo: GeoLocation(latitude: 41.8839, longitude: -87.6324)
                ),
                contact: ContactInfo(email: "hello@rainbow.example.org", phone: "555-333-4444", preferredChannel: .email),
                verified: true,
                ownerUid: "user-jules",
                createdAt: lastWeek,
                updatedAt: now
            )
        ]

        let membersByOrg: [String: [OrganizationMember]] = [
            "org-rainbow-center": [
                OrganizationMember(
                    id: "user-jules",
                    userId: "user-jules",
                    role: .admin,
                    status: .active,
                    joinedAt: lastWeek,
                    invitedAt: nil
                )
            ]
        ]

        let events: [Event] = [
            Event(
                id: "event-coffee-hour",
                orgId: "org-rainbow-center",
                title: "Community Coffee Hour",
                description: "Low-key hang with neighbors and new volunteers.",
                startsAt: nextFriday,
                endsAt: Calendar.current.date(byAdding: .hour, value: 2, to: nextFriday) ?? nextFriday,
                timezone: "America/Chicago",
                location: LocationInfo(
                    name: "Rainbow Center",
                    address: "124 Community Way",
                    city: "Chicago",
                    region: "IL",
                    postalCode: "60601",
                    country: "US",
                    geo: GeoLocation(latitude: 41.8839, longitude: -87.6324)
                ),
                accessibility: AccessibilityInfo(
                    notes: "Step-free entry and ADA restroom.",
                    tags: ["step-free", "gender-neutral-restroom"]
                ),
                tags: ["social", "coffee"],
                rsvpCap: 20,
                status: .published,
                contact: EventContact(name: "Jules Kim", email: "jules@example.com", phone: nil),
                createdBy: "user-jules",
                createdAt: lastWeek,
                updatedAt: now
            ),
            Event(
                id: "event-kits",
                orgId: "org-rainbow-center",
                title: "Care Kit Assembly",
                description: "Pack hygiene kits for mutual aid partners.",
                startsAt: nextSaturday,
                endsAt: Calendar.current.date(byAdding: .hour, value: 3, to: nextSaturday) ?? nextSaturday,
                timezone: "America/Chicago",
                location: LocationInfo(
                    name: "Rainbow Center",
                    address: "124 Community Way",
                    city: "Chicago",
                    region: "IL",
                    postalCode: "60601",
                    country: "US",
                    geo: GeoLocation(latitude: 41.8839, longitude: -87.6324)
                ),
                accessibility: AccessibilityInfo(
                    notes: "Masks welcome; fragrance-free space.",
                    tags: ["fragrance-free"]
                ),
                tags: ["mutual-aid", "kits"],
                rsvpCap: 12,
                status: .published,
                contact: EventContact(name: "Jules Kim", email: "jules@example.com", phone: nil),
                createdBy: "user-jules",
                createdAt: lastWeek,
                updatedAt: now
            )
        ]

        let rolesByEvent: [String: [EventRole]] = [
            "event-coffee-hour": [
                EventRole(
                    id: "role-host",
                    title: "Host",
                    description: "Welcome volunteers, answer questions.",
                    slotsTotal: 2,
                    slotsFilled: 1,
                    skillsRequired: ["hospitality"],
                    checkInRequired: true,
                    minAge: 18
                )
            ],
            "event-kits": [
                EventRole(
                    id: "role-assembler",
                    title: "Assembler",
                    description: "Assemble care kits with provided supplies.",
                    slotsTotal: 6,
                    slotsFilled: 2,
                    skillsRequired: ["detail"],
                    checkInRequired: true,
                    minAge: 16
                )
            ]
        ]

        let rsvpsByEvent: [String: [RSVP]] = [
            "event-coffee-hour": [
                RSVP(
                    id: "user-alex",
                    userId: "user-alex",
                    roleId: "role-host",
                    status: .rsvp,
                    consent: ConsentSnapshot(
                        shareEmail: false,
                        sharePhone: false,
                        sharePronouns: true,
                        shareAccessibility: true
                    ),
                    answers: ["tshirtSize": "M"],
                    createdAt: lastWeek,
                    updatedAt: now
                )
            ]
        ]

        let attendanceByEvent: [String: [Attendance]] = [
            "event-coffee-hour": [
                Attendance(
                    id: "user-alex",
                    userId: "user-alex",
                    checkedInAt: lastWeek,
                    checkedOutAt: Calendar.current.date(byAdding: .hour, value: 2, to: lastWeek) ?? lastWeek,
                    hours: 2,
                    verifiedBy: "user-jules",
                    notes: "Great energy and welcoming."
                )
            ]
        ]

        let messageThreads: [MessageThread] = [
            MessageThread(
                id: "thread-coffee-hour",
                eventId: "event-coffee-hour",
                orgId: "org-rainbow-center",
                participantUids: ["user-jules", "user-alex"],
                createdAt: lastWeek,
                lastMessageAt: now
            )
        ]

        let messagesByThread: [String: [Message]] = [
            "thread-coffee-hour": [
                Message(
                    id: "msg-1",
                    threadId: "thread-coffee-hour",
                    senderUid: "user-jules",
                    body: "Thanks for signing up! See you Friday.",
                    sentAt: lastWeek
                ),
                Message(
                    id: "msg-2",
                    threadId: "thread-coffee-hour",
                    senderUid: "user-alex",
                    body: "Looking forward to it!",
                    sentAt: now
                )
            ]
        ]

        let notificationsByUser: [String: [NotificationItem]] = [
            "user-alex": [
                NotificationItem(
                    id: "notif-1",
                    type: .eventReminder,
                    title: "Community Coffee Hour",
                    body: "Starts in 24 hours. Bring a mug if you can.",
                    deepLink: "volunqueer://events/event-coffee-hour",
                    createdAt: now,
                    readAt: nil
                )
            ]
        ]

        return MockDataBundle(
            users: users,
            organizations: organizations,
            membersByOrg: membersByOrg,
            events: events,
            rolesByEvent: rolesByEvent,
            rsvpsByEvent: rsvpsByEvent,
            attendanceByEvent: attendanceByEvent,
            messageThreads: messageThreads,
            messagesByThread: messagesByThread,
            notificationsByUser: notificationsByUser
        )
    }()
}

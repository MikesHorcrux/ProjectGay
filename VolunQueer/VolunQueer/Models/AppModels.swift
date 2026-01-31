//
//  AppModels.swift
//  VolunQueer
//
//  Data models aligned with the Firestore schema in README.
//

import Foundation

// MARK: - Users

struct AppUser: Identifiable, Codable, Hashable {
    var id: String
    var displayName: String
    var pronouns: String?
    var photoURL: String?
    var roles: [UserRole]
    var status: AccountStatus
    var visibility: UserVisibility
    var contact: ContactInfo?
    var volunteerProfile: VolunteerProfile?
    var organizerProfile: OrganizerProfile?
    var impactSummary: ImpactSummary?
    var createdAt: Date
    var updatedAt: Date
}

enum UserRole: String, Codable, Hashable {
    case volunteer
    case organizer
    case programAdmin
}

enum AccountStatus: String, Codable, Hashable {
    case active
    case suspended
    case archived
}

struct UserVisibility: Codable, Hashable {
    var shareEmail: Bool
    var sharePhone: Bool
    var sharePronouns: Bool
    var shareAccessibility: Bool
}

struct ContactInfo: Codable, Hashable {
    var email: String?
    var phone: String?
    var preferredChannel: ContactChannel?
}

enum ContactChannel: String, Codable, Hashable {
    case email
    case sms
    case push
}

struct VolunteerProfile: Codable, Hashable {
    var interests: [String]
    var skills: [String]
    var availability: Availability?
    var accessibilityNeeds: [String]?
    var location: GeoLocation?
    var bio: String?
    var experienceNotes: String?
}

struct OrganizerProfile: Codable, Hashable {
    var orgIds: [String]
    var contactRole: String?
    var verified: Bool
}

// MARK: - Organizations

struct Organization: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var mission: String?
    var website: String?
    var location: LocationInfo?
    var contact: ContactInfo?
    var verified: Bool
    var ownerUid: String
    var createdAt: Date
    var updatedAt: Date
}

struct OrganizationMember: Identifiable, Codable, Hashable {
    var id: String
    var userId: String
    var role: OrganizationRole
    var status: MembershipStatus
    var joinedAt: Date?
    var invitedAt: Date?
}

enum OrganizationRole: String, Codable, Hashable {
    case admin
    case staff
    case viewer
}

enum MembershipStatus: String, Codable, Hashable {
    case active
    case invited
    case removed
}

// MARK: - Events

struct Event: Identifiable, Codable, Hashable {
    var id: String
    var orgId: String
    var title: String
    var description: String?
    var startsAt: Date
    var endsAt: Date
    var timezone: String
    var location: LocationInfo
    var accessibility: AccessibilityInfo?
    var tags: [String]
    var rsvpCap: Int?
    var status: EventStatus
    var contact: EventContact?
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date
}

enum EventStatus: String, Codable, Hashable {
    case draft
    case published
    case cancelled
    case archived
}

struct LocationInfo: Codable, Hashable {
    var name: String?
    var address: String?
    var city: String?
    var region: String?
    var postalCode: String?
    var country: String?
    var geo: GeoLocation?
}

struct EventContact: Codable, Hashable {
    var name: String?
    var email: String?
    var phone: String?
}

struct AccessibilityInfo: Codable, Hashable {
    var notes: String?
    var tags: [String]?
}

struct EventRole: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var description: String?
    var slotsTotal: Int
    var slotsFilled: Int
    var skillsRequired: [String]
    var checkInRequired: Bool
    var minAge: Int?
}

// MARK: - RSVPs and Attendance

struct RSVP: Identifiable, Codable, Hashable {
    var id: String
    var userId: String
    var roleId: String?
    var status: RSVPStatus
    var consent: ConsentSnapshot
    var answers: [String: String]?
    var createdAt: Date
    var updatedAt: Date
}

enum RSVPStatus: String, Codable, Hashable {
    case rsvp
    case waitlisted
    case cancelled
    case noShow
}

struct ConsentSnapshot: Codable, Hashable {
    var shareEmail: Bool
    var sharePhone: Bool
    var sharePronouns: Bool
    var shareAccessibility: Bool
}

struct Attendance: Identifiable, Codable, Hashable {
    var id: String
    var userId: String
    var checkedInAt: Date?
    var checkedOutAt: Date?
    var hours: Double?
    var verifiedBy: String?
    var notes: String?
}

// MARK: - Communication

struct MessageThread: Identifiable, Codable, Hashable {
    var id: String
    var eventId: String?
    var orgId: String?
    var participantUids: [String]
    var createdAt: Date
    var lastMessageAt: Date?
}

struct Message: Identifiable, Codable, Hashable {
    var id: String
    var threadId: String
    var senderUid: String
    var body: String
    var sentAt: Date
}

struct NotificationItem: Identifiable, Codable, Hashable {
    var id: String
    var type: NotificationType
    var title: String
    var body: String
    var deepLink: String?
    var createdAt: Date
    var readAt: Date?
}

enum NotificationType: String, Codable, Hashable {
    case eventReminder
    case rsvpUpdate
    case orgMessage
    case system
}

// MARK: - Supporting Types

struct GeoLocation: Codable, Hashable {
    var latitude: Double
    var longitude: Double
}

struct Availability: Codable, Hashable {
    var timezone: String
    var weekly: [WeekdayAvailability]
}

struct WeekdayAvailability: Codable, Hashable {
    var weekday: Weekday
    var windows: [TimeWindow]
}

struct TimeWindow: Codable, Hashable {
    var startMinutes: Int
    var endMinutes: Int
}

enum Weekday: String, Codable, Hashable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

struct ImpactSummary: Codable, Hashable {
    var totalHours: Double
    var eventsAttended: Int
    var lastEventAt: Date?
}

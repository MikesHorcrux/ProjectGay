# VolunQueer

VolunQueer connects volunteers with LGBTQ+ events, streamlines coordination, and tracks community impact.

## Firebase + Firestore setup (required)

This repo does **not** commit `GoogleService-Info.plist`. Each developer must add their own copy locally.

1. Create or select a Firebase project.
2. Add an iOS app to the project:
   - Bundle ID: `com.Cephalopod.VolunQueer`
   - (Optional) App nickname: VolunQueer
3. Download `GoogleService-Info.plist`.
   - If you change the bundle ID in Xcode, you must register that new ID in Firebase and re-download the plist.
4. In Xcode, add the plist to the app target:
   - Open `VolunQueer/VolunQueer.xcodeproj`
   - Drag `GoogleService-Info.plist` into the `VolunQueer` target
   - Ensure "Copy items if needed" and the `VolunQueer` target are checked
5. In the Firebase console, enable Firestore:
   - Build > Firestore Database
   - Create a database (start in Test Mode for local dev if desired)

Note: `GoogleService-Info.plist` is ignored by git in this repo. Do not commit it.

## Data model (Firestore)

These are the recommended collections and core fields. Keep PII minimal and use consent flags
to control what organizers can see.

`users/{uid}`
- `displayName`
- `pronouns` (optional)
- `photoURL` (optional)
- `roles` (volunteer, organizer, programAdmin)
- `status` (active, suspended, archived)
- `visibility` (map: shareEmail, sharePhone, sharePronouns, shareAccessibility)
- `contact` (private map: email, phone)
- `volunteerProfile` (map: interests, skills, availability, accessibilityNeeds, location)
- `organizerProfile` (map: orgIds, contactRole, verified)
- `impactSummary` (map: totalHours, eventsAttended, lastEventAt)
- `createdAt`, `updatedAt`

`organizations/{orgId}`
- `name`
- `mission`
- `website`
- `location` (map: latitude, longitude, address)
- `contact` (email, phone)
- `verified`
- `ownerUid`
- `createdAt`, `updatedAt`

`organizations/{orgId}/members/{uid}`
- `role` (admin, staff, viewer)
- `status` (active, invited, removed)
- `joinedAt`, `invitedAt`

`events/{eventId}`
- `orgId`
- `title`, `description`
- `startsAt`, `endsAt`, `timezone`
- `location` (map: address, city, region, postalCode, country, latitude, longitude)
- `accessibility` (map: notes, tags)
- `tags`
- `rsvpCap`
- `status` (draft, published, cancelled, archived)
- `contact` (name, email, phone)
- `createdBy`, `createdAt`, `updatedAt`

`events/{eventId}/roles/{roleId}`
- `title`, `description`
- `slotsTotal`, `slotsFilled`
- `skillsRequired`
- `checkInRequired`
- `minAge`

`events/{eventId}/rsvps/{uid}`
- `roleId`
- `status` (rsvp, waitlisted, cancelled, noShow)
- `consent` (map: shareEmail, sharePhone, sharePronouns, shareAccessibility)
- `answers` (map)
- `createdAt`, `updatedAt`

`events/{eventId}/attendance/{uid}`
- `checkedInAt`, `checkedOutAt`
- `hours`
- `verifiedBy`
- `notes`

`messageThreads/{threadId}`
- `eventId` (optional)
- `orgId` (optional)
- `participantUids`
- `createdAt`, `lastMessageAt`

`messageThreads/{threadId}/messages/{messageId}`
- `senderUid`
- `body`
- `sentAt`

`users/{uid}/notifications/{notificationId}`
- `type` (eventReminder, rsvpUpdate, orgMessage, system)
- `title`, `body`
- `deepLink` (optional)
- `createdAt`, `readAt`

## Run

1. Open `VolunQueer/VolunQueer.xcodeproj` in Xcode.
2. Build and run on a simulator or device.

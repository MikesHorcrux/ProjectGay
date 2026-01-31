import Foundation

/// Event + RSVP pairing for the volunteer RSVP list.
struct RSVPListRow: Identifiable, Hashable {
    let event: Event
    let rsvp: RSVP

    var id: String { event.id }
}

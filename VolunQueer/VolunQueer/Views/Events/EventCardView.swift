import SwiftUI

/// Card view for volunteer discovery listings.
struct EventCardView: View {
    let event: Event
    let store: AppStore
    let rsvpStatus: RSVPStatus?

    private var roles: [EventRole] { store.roles(for: event) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Text(event.title)
                    .font(.headline)
                    .foregroundStyle(Theme.softCharcoal)
                    .multilineTextAlignment(.leading)

                Spacer()

                if let badge = badgeText {
                    Text(badge)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .foregroundStyle(badgeForeground)
                        .background(badgeBackground)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(Theme.skyTeal)
                Text(whenText)
                    .font(.subheadline)
                    .foregroundStyle(Theme.softCharcoal.opacity(0.9))
            }

            HStack(spacing: 6) {
                Image(systemName: "mappin.circle")
                    .font(.caption)
                    .foregroundStyle(Theme.skyTeal)
                Text(whereText)
                    .font(.subheadline)
                    .foregroundStyle(Theme.softCharcoal.opacity(0.9))
                    .lineLimit(1)
            }

            if !event.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(event.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.lavenderMist)
                                .foregroundStyle(Theme.softCharcoal)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            if let cap = event.rsvpCap, cap > 0 {
                Text(spotsText)
                    .font(.caption)
                    .foregroundStyle(Theme.softCharcoal.opacity(0.8))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var whenText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d · h:mm a"
        formatter.timeZone = TimeZone(identifier: event.timezone) ?? .current
        return formatter.string(from: event.startsAt)
    }

    private var whereText: String {
        event.location.name ?? event.location.address ?? event.location.city ?? "Location TBD"
    }

    private var spotsText: String {
        guard let cap = event.rsvpCap, cap > 0 else { return "" }
        let totalSlots = roles.reduce(0) { $0 + $1.slotsTotal }
        let filled = roles.reduce(0) { $0 + $1.slotsFilled }
        if totalSlots > 0 {
            let left = totalSlots - filled
            return "\(left) of \(totalSlots) spots left"
        }
        return "\(cap) spots"
    }

    private var isFull: Bool {
        let totalSlots = roles.reduce(0) { $0 + $1.slotsTotal }
        let filled = roles.reduce(0) { $0 + $1.slotsFilled }
        guard totalSlots > 0 else { return false }
        if let cap = event.rsvpCap, cap > 0 {
            return filled >= min(totalSlots, cap)
        }
        return filled >= totalSlots
    }

    private var badgeText: String? {
        if let rsvpStatus {
            switch rsvpStatus {
            case .rsvp:
                return "RSVP'd"
            case .waitlisted:
                return "Waitlist"
            case .cancelled:
                return nil
            case .noShow:
                return "No show"
            }
        }
        return isFull ? "Full" : nil
    }

    private var badgeForeground: Color {
        if let rsvpStatus {
            switch rsvpStatus {
            case .rsvp:
                return Theme.skyTeal
            case .waitlisted:
                return .orange
            case .cancelled, .noShow:
                return .secondary
            }
        }
        return .secondary
    }

    private var badgeBackground: Color {
        badgeForeground.opacity(0.15)
    }
}

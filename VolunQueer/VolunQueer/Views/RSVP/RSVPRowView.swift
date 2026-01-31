import SwiftUI

/// Summary card for a single RSVP entry.
struct RSVPRowView: View {
    let event: Event
    let status: RSVPStatus
    let roleTitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundStyle(Theme.softCharcoal)

                    Text(dateText)
                        .font(.subheadline)
                        .foregroundStyle(Theme.softCharcoal.opacity(0.9))

                    Text(locationText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(statusLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .foregroundStyle(statusForeground)
                    .background(statusBackground)
                    .clipShape(Capsule())
            }

            if let roleTitle {
                Text("Role: \(roleTitle)")
                    .font(.caption)
                    .foregroundStyle(Theme.softCharcoal.opacity(0.85))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d · h:mm a"
        formatter.timeZone = TimeZone(identifier: event.timezone) ?? .current
        return formatter.string(from: event.startsAt)
    }

    private var locationText: String {
        event.location.name ?? event.location.city ?? "Location TBD"
    }

    private var statusLabel: String {
        switch status {
        case .rsvp:
            return "RSVP'd"
        case .waitlisted:
            return "Waitlist"
        case .cancelled:
            return "Cancelled"
        case .noShow:
            return "No Show"
        }
    }

    private var statusForeground: Color {
        switch status {
        case .rsvp:
            return Theme.skyTeal
        case .waitlisted:
            return .orange
        case .cancelled, .noShow:
            return .secondary
        }
    }

    private var statusBackground: Color {
        statusForeground.opacity(0.15)
    }
}

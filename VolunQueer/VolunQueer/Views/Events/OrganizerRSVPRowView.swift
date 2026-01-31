import SwiftUI

/// Row for an organizer viewing a volunteer RSVP.
struct OrganizerRSVPRowView: View {
    let displayName: String
    let roleTitle: String?
    let status: RSVPStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(displayName)
                    .font(.headline)
                    .foregroundStyle(Theme.softCharcoal)

                Spacer()

                Text(statusLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .foregroundStyle(statusForeground)
                    .background(statusForeground.opacity(0.15))
                    .clipShape(Capsule())
            }

            if let roleTitle {
                Text("Role: \(roleTitle)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
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
}

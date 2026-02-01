import SwiftUI

/// Organizer card row with event status and quick details.
struct OrganizerEventRowView: View {
    let event: Event
    let store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                EventCardView(event: event, store: store, rsvpStatus: nil)
                Text(statusLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .foregroundStyle(statusForeground)
                    .background(statusForeground.opacity(0.15))
                    .clipShape(Capsule())
                    .padding(10)
            }
            coverageSummary
        }
    }

    private var statusLabel: String {
        switch event.status {
        case .draft:
            return "Draft"
        case .published:
            return "Published"
        case .cancelled:
            return "Cancelled"
        case .archived:
            return "Archived"
        }
    }

    private var statusForeground: Color {
        switch event.status {
        case .draft:
            return .secondary
        case .published:
            return Theme.skyTeal
        case .cancelled:
            return .orange
        case .archived:
            return .secondary
        }
    }

    private var coverageSummary: some View {
        let roles = store.roles(for: event)
        let totals = roles.reduce(into: (total: 0, filled: 0)) { result, role in
            result.total += role.slotsTotal
            result.filled += role.slotsFilled
        }
        let openSlots = max(totals.total - totals.filled, 0)

        return HStack(spacing: 12) {
            if totals.total > 0 {
                Text("Filled \(totals.filled)/\(totals.total)")
                Text("Open \(openSlots)")
            } else {
                Text("No roles yet")
            }

            if let cap = event.rsvpCap {
                Text("Cap \(cap)")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    let store = AppStore(dataSource: .mock, preload: true)
    OrganizerEventRowView(event: MockData.bundle.events[0], store: store)
}

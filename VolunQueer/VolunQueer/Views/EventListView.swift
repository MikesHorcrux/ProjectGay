import SwiftUI

/// Volunteer discovery: list of event cards (when/where, tags, spots).
struct EventListView: View {
    @EnvironmentObject private var store: AppStore

    private var events: [Event] {
        store.publishedEvents.sorted { $0.startsAt < $1.startsAt }
    }

    var body: some View {
        Group {
            if events.isEmpty {
                ContentUnavailableView(
                    "No events yet",
                    systemImage: "calendar.badge.plus",
                    description: Text("Check back soon for volunteer opportunities near you.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(events) { event in
                            NavigationLink(value: event) {
                                EventCardView(event: event, store: store)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Theme.cream)
        .navigationTitle("Discover")
        .navigationDestination(for: Event.self) { event in
            EventDetailView(event: event)
        }
    }
}

// MARK: - Event card (title → when/where → role(s) → spots)

private struct EventCardView: View {
    let event: Event
    let store: AppStore

    private var roles: [EventRole] { store.roles(for: event) }
    private var org: Organization? { store.organization(for: event) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(event.title)
                .font(.headline)
                .foregroundStyle(Theme.softCharcoal)
                .multilineTextAlignment(.leading)

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
                HStack {
                    Text(spotsText)
                        .font(.caption)
                        .foregroundStyle(Theme.softCharcoal.opacity(0.8))
                }
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
}

#Preview {
    NavigationStack {
        EventListView()
            .environmentObject(AppStore(dataSource: .mock, preload: true))
    }
}

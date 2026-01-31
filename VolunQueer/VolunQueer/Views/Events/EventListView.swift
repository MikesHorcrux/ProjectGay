import SwiftUI

/// Volunteer discovery: list of event cards (when/where, tags, spots).
struct EventListView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var statusViewModel: EventRSVPStatusViewModel

    private var events: [Event] {
        store.publishedEvents.sorted { $0.startsAt < $1.startsAt }
    }

    init(userId: String, service: RSVPService) {
        _statusViewModel = StateObject(wrappedValue: EventRSVPStatusViewModel(userId: userId, service: service))
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
                                EventCardView(
                                    event: event,
                                    store: store,
                                    rsvpStatus: statusViewModel.statuses[event.id]
                                )
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
        .task(id: store.events) {
            await statusViewModel.load(events: store.events)
        }
    }
}

#Preview {
    NavigationStack {
        EventListView(userId: "user-alex", service: MockRSVPService(seed: MockData.bundle))
            .environmentObject(AppStore(dataSource: .mock, preload: true))
    }
}

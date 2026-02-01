import SwiftUI

/// Organizer view for events they manage.
struct OrganizerEventListView: View {
    @EnvironmentObject private var store: AppStore

    let userId: String

    var body: some View {
        Group {
            if let user = store.user(for: userId) {
                let managedEvents = store.events(managedBy: user).sorted { $0.startsAt < $1.startsAt }
                let draftEvents = managedEvents.filter { $0.status == .draft }
                let publishedEvents = managedEvents.filter { $0.status == .published }
                let archivedEvents = managedEvents.filter { $0.status == .cancelled || $0.status == .archived }
                if managedEvents.isEmpty {
                    ContentUnavailableView(
                        "No events yet",
                        systemImage: "calendar.badge.plus",
                        description: Text("Create your first volunteer opportunity.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            if !draftEvents.isEmpty {
                                sectionHeader("Drafts")
                                eventRows(draftEvents)
                            }
                            if !publishedEvents.isEmpty {
                                sectionHeader("Published")
                                eventRows(publishedEvents)
                            }
                            if !archivedEvents.isEmpty {
                                sectionHeader("Archived")
                                eventRows(archivedEvents)
                            }
                        }
                        .padding()
                    }
                }
            } else {
                ContentUnavailableView(
                    "Organizer profile missing",
                    systemImage: "person.crop.circle.badge.exclam",
                    description: Text("Complete onboarding to create events.")
                )
            }
        }
        .background(Theme.cream)
        .navigationDestination(for: Event.self) { event in
            EventDetailView(event: event)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(Theme.softCharcoal)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func eventRows(_ events: [Event]) -> some View {
        ForEach(events) { event in
            NavigationLink(value: event) {
                OrganizerEventRowView(event: event, store: store)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        OrganizerEventListView(userId: "user-jules")
            .environmentObject(AppStore(dataSource: .mock, preload: true))
    }
}

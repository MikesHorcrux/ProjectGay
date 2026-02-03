import SwiftUI

/// Bottom sheet showing events for a selected day.
struct RSVPDayDetailView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let date: Date
    let events: [RSVPListRow]
    let userId: String

    var body: some View {
        NavigationStack {
            Group {
                if events.isEmpty {
                    ContentUnavailableView(
                        "No events",
                        systemImage: "calendar",
                        description: Text("You don't have any RSVPs on this day.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(events) { row in
                                NavigationLink(value: row.event) {
                                    RSVPRowView(
                                        event: row.event,
                                        status: row.rsvp.status,
                                        roleTitle: roleTitle(for: row)
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
            .navigationTitle(formattedDate)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Event.self) { event in
                EventDetailView(event: event)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }

    private func roleTitle(for row: RSVPListRow) -> String? {
        guard let roleId = row.rsvp.roleId else { return nil }
        return store.roles(for: row.event).first { $0.id == roleId }?.title
    }
}

#Preview {
    RSVPDayDetailView(
        date: Date(),
        events: [
            RSVPListRow(
                event: Event(
                    id: "1",
                    orgId: "org-1",
                    title: "Community Cleanup",
                    description: "Help clean up the park",
                    startsAt: Date(),
                    endsAt: Date().addingTimeInterval(3600),
                    timezone: "America/Los_Angeles",
                    location: LocationInfo(name: "Golden Gate Park", address: nil, city: "San Francisco", region: "CA", postalCode: nil, country: nil, geo: nil),
                    accessibility: nil,
                    tags: ["outdoors"],
                    rsvpCap: 20,
                    status: .published,
                    contact: nil,
                    createdBy: "user",
                    createdAt: Date(),
                    updatedAt: Date()
                ),
                rsvp: RSVP(
                    id: "rsvp-1",
                    userId: "user-1",
                    eventId: "1",
                    roleId: nil,
                    status: .rsvp,
                    consent: ConsentSnapshot(shareEmail: true, sharePhone: true, sharePronouns: true, shareAccessibility: true),
                    answers: nil,
                    createdAt: Date(),
                    updatedAt: Date()
                )
            )
        ],
        userId: "user-1"
    )
    .environmentObject(AppStore(dataSource: .mock, preload: true))
}

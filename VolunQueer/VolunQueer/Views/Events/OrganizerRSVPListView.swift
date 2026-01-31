import SwiftUI

/// Organizer view to see RSVPs for an event.
struct OrganizerRSVPListView: View {
    @EnvironmentObject private var store: AppStore

    let event: Event
    let service: RSVPService

    @StateObject private var viewModel: OrganizerRSVPListViewModel

    init(event: Event, service: RSVPService) {
        self.event = event
        self.service = service
        _viewModel = StateObject(wrappedValue: OrganizerRSVPListViewModel(eventId: event.id, service: service))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading RSVPs...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let message = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Unable to load RSVPs",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                } else if viewModel.rsvps.isEmpty {
                    ContentUnavailableView(
                        "No RSVPs yet",
                        systemImage: "checkmark.circle",
                        description: Text("RSVPs will show here as volunteers sign up.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.rsvps) { rsvp in
                                OrganizerRSVPRowView(
                                    displayName: displayName(for: rsvp),
                                    roleTitle: roleTitle(for: rsvp),
                                    status: rsvp.status
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Theme.cream)
            .navigationTitle("RSVPs")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.load()
            }
        }
    }

    private func displayName(for rsvp: RSVP) -> String {
        store.users.first { $0.id == rsvp.userId }?.displayName ?? rsvp.userId
    }

    private func roleTitle(for rsvp: RSVP) -> String? {
        guard let roleId = rsvp.roleId else { return nil }
        return store.roles(for: event).first { $0.id == roleId }?.title
    }
}

#Preview {
    OrganizerRSVPListView(event: MockData.bundle.events[0], service: MockRSVPService(seed: MockData.bundle))
        .environmentObject(AppStore(dataSource: .mock, preload: true))
}

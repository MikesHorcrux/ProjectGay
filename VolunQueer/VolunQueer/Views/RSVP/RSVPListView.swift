import SwiftUI

/// Tab view for showing the current user's RSVPs.
struct RSVPListView: View {
    @EnvironmentObject private var store: AppStore

    private let userId: String
    private let service: RSVPService
    @StateObject private var viewModel: RSVPListViewModel
    @State private var viewMode: ViewMode = .list

    enum ViewMode {
        case list
        case calendar
    }

    init(userId: String, service: RSVPService) {
        self.userId = userId
        self.service = service
        _viewModel = StateObject(wrappedValue: RSVPListViewModel(userId: userId, service: service))
    }

    var body: some View {
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
            } else if viewModel.rows.isEmpty {
                ContentUnavailableView(
                    "No RSVPs yet",
                    systemImage: "calendar.badge.plus",
                    description: Text("Browse events and RSVP to keep track here.")
                )
            } else {
                switch viewMode {
                case .list:
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.rows) { row in
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
                case .calendar:
                    RSVPCalendarView(
                        rows: viewModel.rows,
                        userId: userId
                    )
                }
            }
        }
        .background(Theme.cream)
        .navigationTitle("My RSVPs")
        .navigationDestination(for: Event.self) { event in
            EventDetailView(event: event)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("View Mode", selection: $viewMode) {
                    Label("List", systemImage: "list.bullet").tag(ViewMode.list)
                    Label("Calendar", systemImage: "calendar").tag(ViewMode.calendar)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
        }
        .task(id: store.events) {
            await viewModel.load(events: store.events)
        }
    }

    private func roleTitle(for row: RSVPListRow) -> String? {
        guard let roleId = row.rsvp.roleId else { return nil }
        return store.roles(for: row.event).first { $0.id == roleId }?.title
    }
}

#Preview {
    NavigationStack {
        RSVPListView(userId: "user-alex", service: MockRSVPService(seed: MockData.bundle))
            .environmentObject(AppStore(dataSource: .mock, preload: true))
    }
}

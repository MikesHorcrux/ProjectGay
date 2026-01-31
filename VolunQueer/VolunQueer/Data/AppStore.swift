import Foundation
import Combine

/// Observable store that loads app data from mock or Firestore sources.
@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var users: [AppUser] = []
    @Published private(set) var organizations: [Organization] = []
    @Published private(set) var events: [Event] = []
    @Published private(set) var rolesByEvent: [String: [EventRole]] = [:]
    @Published private(set) var currentUserRsvps: [String: RSVP] = [:]
    @Published private(set) var loadState: AppStoreLoadState = .idle

    let dataSource: AppStoreDataSource
    private let firestore: FirestoreClient?

    /// Creates a store with the specified data source.
    init(dataSource: AppStoreDataSource, preload: Bool = false) {
        self.dataSource = dataSource
        self.firestore = dataSource == .firestore ? FirestoreClient() : nil

        if preload, dataSource == .mock {
            applyMockData()
            loadState = .loaded
        }
    }

    /// Loads core collections into memory.
    func load() async {
        loadState = .loading
        do {
            switch dataSource {
            case .mock:
                applyMockData()
                loadState = .loaded
            case .firestore:
                guard let firestore else {
                    loadState = .failed("Firestore unavailable")
                    return
                }
                async let usersTask = firestore.fetchCollection("users", as: AppUser.self)
                async let organizationsTask = firestore.fetchCollection("organizations", as: Organization.self)
                async let eventsTask = firestore.fetchCollection("events", as: Event.self)

                users = try await usersTask
                organizations = try await organizationsTask
                events = try await eventsTask
                loadState = .loaded
            }
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    /// Seeds Firestore with mock data when running in Firestore mode.
    func seedMockData() async {
        guard dataSource == .firestore, let firestore else { return }
        loadState = .loading
        do {
            let shouldSeed = try await firestore.collectionIsEmpty("events")
            if shouldSeed {
                try await firestore.seed(bundle: MockData.bundle)
            }
            await load()
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    /// Applies bundled mock data without hitting Firestore.
    private func applyMockData() {
        let bundle = MockData.bundle
        users = bundle.users
        organizations = bundle.organizations
        events = bundle.events
        rolesByEvent = bundle.rolesByEvent
    }

    /// Organization that hosts the given event.
    func organization(for event: Event) -> Organization? {
        organizations.first { $0.id == event.orgId }
    }

    /// Roles for an event (from mock bundle; Firestore subcollection can be wired later).
    func roles(for event: Event) -> [EventRole] {
        rolesByEvent[event.id] ?? []
    }

    /// RSVP for the current user, if loaded.
    func rsvp(for event: Event, userId: String) -> RSVP? {
        if let rsvp = currentUserRsvps[event.id], rsvp.userId == userId {
            return rsvp
        }
        return nil
    }

    /// Loads the current user's RSVP for an event.
    func loadRsvp(for event: Event, userId: String) async {
        switch dataSource {
        case .mock:
            if let rsvp = MockData.bundle.rsvpsByEvent[event.id]?.first(where: { $0.userId == userId }) {
                currentUserRsvps[event.id] = rsvp
            } else {
                currentUserRsvps.removeValue(forKey: event.id)
            }
        case .firestore:
            guard let firestore else { return }
            do {
                let rsvp = try await firestore.fetchDocument("events/\(event.id)/rsvps", id: userId, as: RSVP.self)
                currentUserRsvps[event.id] = rsvp
            } catch {
                loadState = .failed(error.localizedDescription)
            }
        }
    }

    /// Creates or updates an RSVP for the current user.
    func submitRsvp(for event: Event, userId: String, roleId: String? = nil) async {
        let now = Date()
        let existing = currentUserRsvps[event.id]
        let rsvp = RSVP(
            id: userId,
            userId: userId,
            roleId: roleId,
            status: .rsvp,
            consent: ConsentSnapshot(
                shareEmail: false,
                sharePhone: false,
                sharePronouns: true,
                shareAccessibility: true
            ),
            answers: nil,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now
        )

        currentUserRsvps[event.id] = rsvp

        guard let firestore else { return }
        if dataSource == .firestore {
            do {
                try await firestore.setDocument("events/\(event.id)/rsvps", id: userId, value: rsvp)
            } catch {
                loadState = .failed(error.localizedDescription)
            }
        }
    }

    /// Cancels the current user's RSVP.
    func cancelRsvp(for event: Event, userId: String) async {
        guard var rsvp = currentUserRsvps[event.id] else { return }
        rsvp.status = .cancelled
        rsvp.updatedAt = Date()
        currentUserRsvps[event.id] = rsvp

        guard let firestore else { return }
        if dataSource == .firestore {
            do {
                try await firestore.setDocument("events/\(event.id)/rsvps", id: userId, value: rsvp)
            } catch {
                loadState = .failed(error.localizedDescription)
            }
        }
    }

    /// Published events suitable for discovery.
    var publishedEvents: [Event] {
        events.filter { $0.status == .published }
    }
}

import Foundation
import Combine

/// Observable store that loads app data from mock or Firestore sources.
@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var users: [AppUser] = []
    @Published private(set) var organizations: [Organization] = []
    @Published private(set) var events: [Event] = []
    @Published private(set) var rolesByEvent: [String: [EventRole]] = [:]
    @Published private(set) var loadState: AppStoreLoadState = .idle

    let dataSource: AppStoreDataSource
    /// RSVP persistence for the volunteer flow.
    let rsvpService: RSVPService
    private let firestore: FirestoreClient?

    /// Creates a store with the specified data source.
    init(dataSource: AppStoreDataSource, preload: Bool = false) {
        self.dataSource = dataSource
        let firestoreClient = dataSource == .firestore ? FirestoreClient() : nil
        self.firestore = firestoreClient
        if let firestoreClient {
            rsvpService = FirestoreRSVPService(client: firestoreClient)
        } else {
            rsvpService = MockRSVPService(seed: MockData.bundle)
        }

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
                rolesByEvent = try await fetchRoles(for: events, using: firestore)
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

    /// User profile for the given ID.
    func user(for id: String) -> AppUser? {
        users.first { $0.id == id }
    }

    /// Roles for an event, keyed by event ID.
    func roles(for event: Event) -> [EventRole] {
        rolesByEvent[event.id] ?? []
    }

    /// Events that the given organizer can manage.
    func events(managedBy user: AppUser) -> [Event] {
        let orgIds = Set(user.organizerProfile?.orgIds ?? [])
        return events.filter { event in
            event.createdBy == user.id || orgIds.contains(event.orgId)
        }
    }

    /// Saves a user profile and updates local state.
    func saveUser(_ user: AppUser) async throws {
        if dataSource == .firestore, let firestore {
            try await firestore.setDocument("users", id: user.id, value: user)
        }
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        } else {
            users.append(user)
        }
    }

    /// Saves an organization and updates local state.
    func saveOrganization(_ organization: Organization) async throws {
        if dataSource == .firestore, let firestore {
            try await firestore.setDocument("organizations", id: organization.id, value: organization)
        }
        if let index = organizations.firstIndex(where: { $0.id == organization.id }) {
            organizations[index] = organization
        } else {
            organizations.append(organization)
        }
    }

    /// Saves an event and updates local state.
    func saveEvent(_ event: Event) async throws {
        if dataSource == .firestore, let firestore {
            try await firestore.setDocument("events", id: event.id, value: event)
        }
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        } else {
            events.append(event)
        }
    }

    /// Saves roles for an event and updates local state.
    func saveRoles(_ roles: [EventRole], for eventId: String) async throws {
        if dataSource == .firestore, let firestore {
            let path = "events/\(eventId)/roles"
            let existingRoles = rolesByEvent[eventId] ?? []
            let newIds = Set(roles.map { $0.id })
            let removedRoles = existingRoles.filter { !newIds.contains($0.id) }
            for role in removedRoles {
                try await firestore.deleteDocument(path, id: role.id)
            }
            for role in roles {
                try await firestore.setDocument(path, id: role.id, value: role)
            }
        }
        rolesByEvent[eventId] = roles
    }

    /// Published events suitable for discovery.
    var publishedEvents: [Event] {
        events.filter { $0.status == .published }
    }

    private func fetchRoles(for events: [Event], using firestore: FirestoreClient) async throws -> [String: [EventRole]] {
        var rolesLookup: [String: [EventRole]] = [:]
        for event in events {
            let roles = try await firestore.fetchCollection("events/\(event.id)/roles", as: EventRole.self)
            rolesLookup[event.id] = roles
        }
        return rolesLookup
    }
}

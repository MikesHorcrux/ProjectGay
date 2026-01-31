import Foundation
import Combine

/// Observable store that loads app data from mock or Firestore sources.
@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var users: [AppUser] = []
    @Published private(set) var organizations: [Organization] = []
    @Published private(set) var events: [Event] = []
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
    }
}

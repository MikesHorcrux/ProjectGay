import SwiftUI

/// Root view: loads data, then shows volunteer discovery (event list → event detail).
struct ContentView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            Group {
                switch store.loadState {
                case .idle:
                    Color.clear
                        .onAppear {
                            Task { await store.load() }
                        }
                case .loading:
                    ProgressView("Loading data...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Theme.cream)
                case .loaded:
                    EventListView()
                case .failed(let message):
                    ContentUnavailableView(
                        "Unable to load data",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                }
            }
            .navigationTitle("VolunQueer")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reload") {
                        Task { await store.load() }
                    }
                }

                if store.dataSource == .firestore {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Seed Firestore") {
                            Task { await store.seedMockData() }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStore(dataSource: .mock, preload: true))
}

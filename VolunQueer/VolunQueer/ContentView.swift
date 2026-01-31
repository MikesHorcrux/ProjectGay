//
//  ContentView.swift
//  VolunQueer
//
//  Created by Matthew Waller on 1/30/26.
//

import SwiftUI

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
                case .loaded:
                    List {
                        Section("Overview") {
                            LabeledContent("Data Source", value: store.dataSource.rawValue)
                            LabeledContent("Users", value: "\(store.users.count)")
                            LabeledContent("Organizations", value: "\(store.organizations.count)")
                            LabeledContent("Events", value: "\(store.events.count)")
                        }

                        Section("Events") {
                            ForEach(store.events) { event in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(event.title)
                                        .font(.headline)
                                    if let description = event.description {
                                        Text(description)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(event.location.name ?? "Location TBD")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
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

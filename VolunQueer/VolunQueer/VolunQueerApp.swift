//
//  VolunQueerApp.swift
//  VolunQueer
//
//  Created by Matthew Waller on 1/30/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct VolunQueerApp: App {
    @StateObject private var store = AppStore(
        dataSource: AppConfiguration.dataSource,
        preload: AppConfiguration.dataSource == .mock
    )

    init() {
        if AppConfiguration.dataSource == .firestore {
            FirebaseApp.configure()
            _ = Firestore.firestore()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .task {
                    if AppConfiguration.seedOnLaunch, store.dataSource == .firestore {
                        await store.seedMockData()
                    }
                }
        }
    }
}

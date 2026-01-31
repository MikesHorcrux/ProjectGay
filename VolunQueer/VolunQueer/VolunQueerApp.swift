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
    init() {
        FirebaseApp.configure()
        _ = Firestore.firestore()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

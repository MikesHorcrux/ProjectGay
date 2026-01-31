//
//  AppConfiguration.swift
//  VolunQueer
//

import Foundation

struct AppConfiguration {
    static var dataSource: AppStoreDataSource {
        let value = ProcessInfo.processInfo.environment["VOLUNQUEER_DATA_SOURCE"]?.lowercased()
        switch value {
        case "firestore":
            return .firestore
        case "mock":
            return .mock
        default:
            return .mock
        }
    }

    static var seedOnLaunch: Bool {
        ProcessInfo.processInfo.environment["VOLUNQUEER_SEED"] == "1"
    }
}

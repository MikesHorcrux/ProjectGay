//
//  AppStoreLoadState.swift
//  VolunQueer
//

import Foundation

enum AppStoreLoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

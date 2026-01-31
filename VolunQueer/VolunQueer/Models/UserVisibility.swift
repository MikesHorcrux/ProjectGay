//
//  UserVisibility.swift
//  VolunQueer
//

import Foundation

struct UserVisibility: Codable, Hashable {
    var shareEmail: Bool
    var sharePhone: Bool
    var sharePronouns: Bool
    var shareAccessibility: Bool
}

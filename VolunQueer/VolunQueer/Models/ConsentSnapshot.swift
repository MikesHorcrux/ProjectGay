//
//  ConsentSnapshot.swift
//  VolunQueer
//

import Foundation

struct ConsentSnapshot: Codable, Hashable {
    var shareEmail: Bool
    var sharePhone: Bool
    var sharePronouns: Bool
    var shareAccessibility: Bool
}

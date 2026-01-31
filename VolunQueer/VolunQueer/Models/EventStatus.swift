//
//  EventStatus.swift
//  VolunQueer
//

import Foundation

enum EventStatus: String, Codable, Hashable {
    case draft
    case published
    case cancelled
    case archived
}

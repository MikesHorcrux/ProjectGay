//
//  FirestoreCoding.swift
//  VolunQueer
//
//  Codable helpers for storing and reading documents in Firestore.
//

import Foundation

enum FirestoreCoding {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

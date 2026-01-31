//
//  FirestoreDocument.swift
//  VolunQueer
//

import Foundation

protocol FirestoreDocument: Codable {
    var id: String { get }
}

extension FirestoreDocument {
    func asFirestoreData(includeId: Bool = false) throws -> [String: Any] {
        let data = try FirestoreCoding.encoder.encode(self)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        var dict = json as? [String: Any] ?? [:]
        if !includeId {
            dict.removeValue(forKey: "id")
        }
        return dict
    }

    static func fromFirestoreData(id: String, data: [String: Any]) throws -> Self {
        var payload = data
        payload["id"] = id
        let json = try JSONSerialization.data(withJSONObject: payload, options: [])
        return try FirestoreCoding.decoder.decode(Self.self, from: json)
    }
}

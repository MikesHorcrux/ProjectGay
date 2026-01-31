import Foundation

/// Protocol for Firestore-storable models.
protocol FirestoreDocument: Codable {
    /// Document identifier used as the Firestore document ID.
    var id: String { get }
    /// Encodes the model as Firestore-ready data.
    func asFirestoreData(includeId: Bool) throws -> [String: Any]
}

extension FirestoreDocument {
    /// Encodes the model as Firestore-ready data.
    func asFirestoreData(includeId: Bool = false) throws -> [String: Any] {
        let data = try FirestoreCoding.encoder.encode(self)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        var dict = json as? [String: Any] ?? [:]
        if !includeId {
            dict.removeValue(forKey: "id")
        }
        return dict
    }

    /// Decodes a model from Firestore data and a document ID.
    static func fromFirestoreData(id: String, data: [String: Any]) throws -> Self {
        var payload = data
        payload["id"] = id
        let json = try JSONSerialization.data(withJSONObject: payload, options: [])
        return try FirestoreCoding.decoder.decode(Self.self, from: json)
    }
}

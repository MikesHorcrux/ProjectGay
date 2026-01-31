import Foundation

/// Shared JSON encoder/decoder for Firestore payloads.
enum FirestoreCoding {
    /// Encoder configured for ISO-8601 date storage.
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    /// Decoder configured for ISO-8601 date parsing.
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

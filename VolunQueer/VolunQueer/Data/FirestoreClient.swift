import Foundation
import FirebaseFirestore

/// Thin async wrapper around Firestore operations.
final class FirestoreClient {
    private let db = Firestore.firestore()

    /// Returns true if the collection has no documents.
    func collectionIsEmpty(_ path: String) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            db.collection(path).limit(to: 1).getDocuments { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: snapshot?.documents.isEmpty ?? true)
            }
        }
    }

    /// Loads every document in a collection and decodes to the requested model type.
    func fetchCollection<T: FirestoreDocument>(_ path: String, as type: T.Type) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            db.collection(path).getDocuments { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let items: [T] = snapshot?.documents.compactMap { doc in
                    do {
                        return try T.fromFirestoreData(id: doc.documentID, data: doc.data())
                    } catch {
                        return nil
                    }
                } ?? []
                continuation.resume(returning: items)
            }
        }
    }

    /// Loads a single document by ID from a collection.
    func fetchDocument<T: FirestoreDocument>(_ collectionPath: String, id: String, as type: T.Type) async throws -> T? {
        try await withCheckedThrowingContinuation { continuation in
            db.collection(collectionPath).document(id).getDocument { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let snapshot, snapshot.exists, let data = snapshot.data() else {
                    continuation.resume(returning: nil)
                    return
                }
                do {
                    let item = try T.fromFirestoreData(id: snapshot.documentID, data: data)
                    continuation.resume(returning: item)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Writes a document using the provided model value.
    func setDocument<T: FirestoreDocument>(_ collectionPath: String, id: String, value: T) async throws {
        let data = try value.asFirestoreData()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.collection(collectionPath).document(id).setData(data) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    /// Deletes a document by ID.
    func deleteDocument(_ collectionPath: String, id: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.collection(collectionPath).document(id).delete { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    /// Seeds Firestore with a mock data bundle.
    func seed(bundle: MockDataBundle) async throws {
        for user in bundle.users {
            try await setDocument("users", id: user.id, value: user)
        }

        for org in bundle.organizations {
            try await setDocument("organizations", id: org.id, value: org)
        }

        for (orgId, members) in bundle.membersByOrg {
            let path = "organizations/\(orgId)/members"
            for member in members {
                try await setDocument(path, id: member.id, value: member)
            }
        }

        for event in bundle.events {
            try await setDocument("events", id: event.id, value: event)
        }

        for (eventId, roles) in bundle.rolesByEvent {
            let path = "events/\(eventId)/roles"
            for role in roles {
                try await setDocument(path, id: role.id, value: role)
            }
        }

        for (eventId, rsvps) in bundle.rsvpsByEvent {
            let path = "events/\(eventId)/rsvps"
            for rsvp in rsvps {
                try await setDocument(path, id: rsvp.id, value: rsvp)
            }
        }

        for (eventId, attendance) in bundle.attendanceByEvent {
            let path = "events/\(eventId)/attendance"
            for entry in attendance {
                try await setDocument(path, id: entry.id, value: entry)
            }
        }

        for thread in bundle.messageThreads {
            try await setDocument("messageThreads", id: thread.id, value: thread)
        }

        for (threadId, messages) in bundle.messagesByThread {
            let path = "messageThreads/\(threadId)/messages"
            for message in messages {
                try await setDocument(path, id: message.id, value: message)
            }
        }

        for (userId, notifications) in bundle.notificationsByUser {
            let path = "users/\(userId)/notifications"
            for notification in notifications {
                try await setDocument(path, id: notification.id, value: notification)
            }
        }
    }
}

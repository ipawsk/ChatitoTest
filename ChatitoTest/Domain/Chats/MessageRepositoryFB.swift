//
//  MessageRepositoryFB.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import FirebaseFirestore

final class MessageRepositoryFB: MessageRepository {
    private let db = Firestore.firestore()

    @discardableResult
    func observe(conversationId: String,
                 onChange: @escaping ([MessageEntity]) -> Void,
                 onError: @escaping (Error) -> Void) -> AnyObject {
        let ref = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "createdAt", descending: false)

        let listener = ref.addSnapshotListener { snap, err in
            if let err = err { onError(err); return }
            guard let snap else { onChange([]); return }
            let messages = snap.documents.compactMap { doc -> MessageEntity? in
                let data = doc.data()
                guard let senderId = data["senderId"] as? String,
                      let text = data["text"] as? String,
                      let ts = data["createdAt"] as? Timestamp else { return nil }
                return MessageEntity(
                    id: doc.documentID,
                    senderId: senderId,
                    text: text,
                    createdAt: ts.dateValue()
                )
            }
            onChange(messages)
        }
        return listener as AnyObject
    }

    func send(conversationId: String,
              senderId: String,
              text: String) async throws {
        let convRef = db.collection("conversations").document(conversationId)
        let msgRef  = convRef.collection("messages").document()
        let now = FieldValue.serverTimestamp()

        try await db.runTransaction { tx, _ in
            tx.setData([
                "senderId": senderId,
                "text": text,
                "createdAt": now
            ], forDocument: msgRef)

            tx.updateData([
                "lastMessage": ["text": text,
                                "senderId": senderId,
                                "createdAt": now],
                "updatedAt": now
            ], forDocument: convRef)
            return nil
        }
    }
}




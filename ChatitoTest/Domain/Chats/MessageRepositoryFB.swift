//
//  MessageRepositoryFB.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import FirebaseFirestore
import FirebaseAuth

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
            if let err = err {
                onError(err)
                return
            }
            guard let snap = snap else {
                onChange([])
                return
            }
            
            let messages: [MessageEntity] = snap.documents.compactMap { doc in
                let data = doc.data()
                
                guard
                    let senderId = data["senderId"] as? String,
                    let text = data["text"] as? String,
                    let ts = data["createdAt"] as? Timestamp
                else {
                    return nil
                }
                
                let username = data["username"] as? String
                
                return MessageEntity(
                    id: doc.documentID,
                    senderId: senderId,
                    username: username,
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
        
        var senderUsername = "User"
        if let userDoc = try? await Firestore.firestore().collection("users").document(senderId).getDocument(),
           let username = userDoc.data()?["username"] as? String {
            senderUsername = username
        }
        
        _ = try await db.runTransaction { tx, _ in
            tx.setData([
                "senderId": senderId,
                "username": senderUsername,
                "text": text,
                "createdAt": now
            ], forDocument: msgRef)
            
            tx.updateData([
                "lastMessage": [
                    "text": text,
                    "senderId": senderId,
                    "username": senderUsername,
                    "createdAt": now
                ],
                "updatedAt": now
            ], forDocument: convRef)
            return nil
        }
    }
}

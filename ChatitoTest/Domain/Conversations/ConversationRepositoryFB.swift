//
//  ConversationRepositoryFB.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import FirebaseFirestore

final class ConversationRepositoryFB: ConversationRepository {
    private let db = Firestore.firestore()
    
    @discardableResult
    func observeMine(userId: String,
                     onChange: @escaping ([ConversationEntity]) -> Void,
                     onError: @escaping (Error) -> Void) -> AnyObject {
        let q = db.collection("conversations")
            .whereField("memberIds", arrayContains: userId)
            .order(by: "updatedAt", descending: true)
        
        let listener = q.addSnapshotListener { snap, err in
            if let err = err { onError(err); return }
            
            guard let snap else {
                onChange([]);
                return
            }
            
            let items: [ConversationEntity] = snap.documents.compactMap { doc in
                let data = doc.data()
                let title = data["title"] as? String
                let memberIds = data["memberIds"] as? [String] ?? []
                let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? .distantPast
                
                var lastText: String?
                var lastAt: Date?
                if let lm = data["lastMessage"] as? [String: Any] {
                    lastText = lm["text"] as? String
                    if let t = lm["createdAt"] as? Timestamp { lastAt = t.dateValue() }
                }
                
                return ConversationEntity(
                    id: doc.documentID,
                    title: title,
                    memberIds: memberIds,
                    lastMessageText: lastText,
                    lastMessageAt: lastAt,
                    updatedAt: updatedAt
                )
            }
            onChange(items)
        }
        return listener as AnyObject
    }
    
    func create(memberIds: [String], title: String?) async throws -> ConversationEntity {
        let ref = db.collection("conversations").document()
        let now = FieldValue.serverTimestamp()
        try await ref.setData([
            "title": title as Any,
            "memberIds": memberIds,
            "members": Dictionary(uniqueKeysWithValues: memberIds.map { ($0, true) }),
            "createdAt": now,
            "updatedAt": now
        ])
        return ConversationEntity(
            id: ref.documentID,
            title: title,
            memberIds: memberIds,
            lastMessageText: nil,
            lastMessageAt: nil,
            updatedAt: Date()
        )
    }
}

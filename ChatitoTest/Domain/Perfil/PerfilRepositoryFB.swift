//
//  PerfilRepositoryFB.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

final class UserRepositoryFirebase: UserRepository {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func fetch(uid: String) async throws -> UserProfileEntity {
        let doc = try await db.collection("users").document(uid).getDocument()
        let data = doc.data() ?? [:]
        let displayName = (data["displayName"] as? String) ?? (Auth.auth().currentUser?.displayName ?? "")
        let username = (data["username"] as? String) ?? (Auth.auth().currentUser?.displayName ?? "")
        let email = (data["email"] as? String) ?? (Auth.auth().currentUser?.email ?? "")
        let photoStr = (data["photoURL"] as? String) ?? Auth.auth().currentUser?.photoURL?.absoluteString
        return UserProfileEntity(uid: uid,
                                 displayName: displayName,
                                 username: username,
                                 photoURL: photoStr.flatMap(URL.init(string:)),
                                 email: email)
    }
    
    func update(uid: String, displayName: String, username: String, photoData: Data?) async throws -> UserProfileEntity {
        var photoURL: URL? = nil
        
        if let photoData {
            let ref = storage.reference(withPath: "users/\(uid)/avatar.jpg")
            _ = try await ref.putDataAsync(photoData, metadata: nil)
            photoURL = try await ref.downloadURL()
        }
        
        if let user = Auth.auth().currentUser {
            let change = user.createProfileChangeRequest()
            change.displayName = displayName
            if let url = photoURL { change.photoURL = url }
            try await change.commitChanges()
            
        }
        
        var update: [String: Any] = [
            "displayName": displayName,
            "username": username.lowercased(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let url = photoURL {
            update["photoURL"] = url.absoluteString
        }
        try await db.collection("users").document(uid).setData(update, merge: true)
        
        return try await fetch(uid: uid)
    }
}

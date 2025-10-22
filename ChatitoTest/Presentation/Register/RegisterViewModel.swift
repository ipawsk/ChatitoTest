//
//  RegisterViewModel.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import FirebaseAuth
import FirebaseFirestore

final class RegisterViewModel {
    var displayName: String = ""
    var username: String = ""
    var email: String = ""
    var password: String = ""

    var onLoading: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: (() -> Void)?

    private let db = Firestore.firestore()

    private func onMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    func register() {
        guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else {
            onError?("Add a name."); return
        }
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            onError?("Add a username."); return
        }
        guard email.contains("@"), email.contains(".") else {
            onError?("InvalidEmailFormat."); return
        }
        guard password.count >= 6 else {
            onError?("Password cannot be shorter than 6 characters."); return
        }

        onMain { self.onLoading?(true) }

        Task {
            do {
                let uname = username.lowercased()
                let exists = try await db.collection("users")
                    .whereField("username", isEqualTo: uname)
                    .getDocuments()
                if exists.documents.count > 0 {
                    self.onMain {
                        self.onLoading?(false)
                        self.onError?("Username is already taken.")
                    }
                    return
                }

                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                let user = result.user

                let change = user.createProfileChangeRequest()
                change.displayName = displayName
                try await change.commitChanges()

                try await db.collection("users").document(user.uid).setData([
                    "displayName": displayName,
                    "username": uname,
                    "email": email,
                    "photoURL": user.photoURL?.absoluteString as Any? ?? NSNull(),
                    "createdAt": FieldValue.serverTimestamp(),
                    "updatedAt": FieldValue.serverTimestamp()
                ], merge: true)

                self.onMain {
                    self.onLoading?(false)
                    self.onSuccess?()
                }
            } catch {
                self.onMain {
                    self.onLoading?(false)
                    self.onError?(AuthErrorFirebaseHelper.firebaseAuthError(error))
                }
            }
        }
    }
}

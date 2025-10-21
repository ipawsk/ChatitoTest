//
//  RegisterViewModel.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import FirebaseAuth
import Foundation

final class RegisterViewModel {
    var displayName: String = ""
    var email: String = ""
    var password: String = ""
    
    var onLoading: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: (() -> Void)?
    
    func register() {
        guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else {
            onError?("Ingresa un nombre.")
            return
        }
        guard email.contains("@"), email.contains(".") else {
            onError?("Correo inválido.")
            return
        }
        guard password.count >= 6 else {
            onError?("La contraseña debe tener al menos 6 caracteres.")
            return
        }
        
        onLoading?(true)
        Task {
            do {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                let change = result.user.createProfileChangeRequest()
                change.displayName = displayName
                try await change.commitChanges()
                onSuccess?()
            } catch {
                onError?(AuthErrorFirebaseHelper.firebaseAuthError(error))
            }
            onLoading?(false)
        }
    }
}

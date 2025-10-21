//
//  LoginViewModel.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import FirebaseAuth
import Foundation

final class LoginViewModel {
    var email: String = ""
    var password: String = ""
    
    var onLoading: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: (() -> Void)?
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            onError?("Por favor completa todos los campos.")
            return
        }
        
        onLoading?(true)
        Task {
            do {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                print(" Usuario autenticado:", result.user.email ?? "")
                onSuccess?()
            } catch {
                onError?(AuthErrorFirebaseHelper.firebaseAuthError(error))
            }
            onLoading?(false)
        }
    }
}

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
            onError?("Please add all information.")
            return
        }
        
        onLoading?(true)
        Task {
            do {
                let _ = try await Auth.auth().signIn(withEmail: email, password: password)
                onSuccess?()
            } catch {
                onError?(AuthErrorFirebaseHelper.firebaseAuthError(error))
            }
            onLoading?(false)
        }
    }
}

//
//  AuthErrorFirebaseHelper.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import FirebaseAuth

enum AuthErrorFirebaseHelper {
    static func firebaseAuthError(_ error: Error) -> String {
        let ns = error as NSError
        switch AuthErrorCode(_bridgedNSError: ns)?.code {
        case .networkError: return "Sin conexión. Intenta de nuevo."
        case .userNotFound, .wrongPassword: return "Correo o contraseña incorrectos."
        case .invalidEmail: return "Correo inválido."
        default: return error.localizedDescription
        }
    }
}

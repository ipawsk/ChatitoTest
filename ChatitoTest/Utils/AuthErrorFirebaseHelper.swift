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
        case .networkError: return "without internet connection, try later again."
        case .userNotFound, .wrongPassword: return "email or passwords incorrects."
        case .invalidEmail: return "invalid email ."
        default: return error.localizedDescription
        }
    }
}

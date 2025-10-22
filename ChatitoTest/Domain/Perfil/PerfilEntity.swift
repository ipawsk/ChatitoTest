//
//  PerfilEntity.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

// Domain/Entities/UserProfileEntity.swift
import Foundation

struct UserProfileEntity: Hashable {
    let uid: String
    var displayName: String
    var username: String?
    var photoURL: URL?
    var email: String
}

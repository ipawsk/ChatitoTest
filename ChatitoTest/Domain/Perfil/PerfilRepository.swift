//
//  PerfilRepository.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import Foundation

protocol UserRepository {
    func fetch(uid: String) async throws -> UserProfileEntity
    func update(uid: String,
                displayName: String,
                username: String,
                photoData: Data?) async throws -> UserProfileEntity
}

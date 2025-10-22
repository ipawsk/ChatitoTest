//
//  PerfilViewModel.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import Foundation
import FirebaseAuth

final class ProfileViewModel {
    var onLoading: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onProfile: ((UserProfileEntity) -> Void)?
    var onSaved: (() -> Void)?

    private let repo: UserRepository
    private let uid: String

    var displayName: String = ""
    var username: String = ""
    var photoData: Data?

    init(repo: UserRepository, uid: String) {
        self.repo = repo
        self.uid = uid
    }

    func load() {
        onLoading?(true)
        Task {
            do {
                let profile = try await repo.fetch(uid: uid)
                displayName = profile.displayName
                onProfile?(profile)
                onLoading?(false)
            } catch {
                onLoading?(false)
                onError?(error.localizedDescription)
            }
        }
    }

    func save() {
        guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else {
            onError?("Write a name.")
            return
        }
        onLoading?(true)
        Task {
            do {
                let updated = try await repo.update(uid: uid,
                                                    displayName: displayName,
                                                    username: username,
                                                    photoData: photoData)
                onProfile?(updated)
                onLoading?(false)
                onSaved?()
            } catch {
                onLoading?(false)
                onError?(error.localizedDescription)
            }
        }
    }
}

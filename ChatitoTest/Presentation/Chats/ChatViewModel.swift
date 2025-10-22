//
//  ChatViewModel.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import Foundation
import FirebaseAuth

final class ChatViewModel {
    struct Row: Hashable {
        let id: String
        let username: String?
        let text: String
        let isMine: Bool
        let time: String
    }
    
    var onUpdate: (([Row]) -> Void)?
    var onError: ((String) -> Void)?
    
    private let repo: MessageRepository
    private let conversationId: String
    private var listener: AnyObject?
    private let currentUserId: String
    
    init(repo: MessageRepository, conversationId: String) {
        self.repo = repo
        self.conversationId = conversationId
        self.currentUserId = Auth.auth().currentUser?.uid ?? ""
    }
    
    func start() {
        listener = repo.observe(conversationId: conversationId,
                                onChange: { [weak self] messages in
            guard let self else { return }
            let df = DateFormatter()
            df.timeStyle = .short
            let rows = messages.map {
                Row(
                    id: $0.id,
                    username: $0.username ?? "user",
                    text: $0.text,
                    isMine: $0.senderId == self.currentUserId,
                    time: df.string(from: $0.createdAt))
            }
            self.onUpdate?(rows)
        }, onError: { [weak self] err in
            self?.onError?(err.localizedDescription)
        })
    }
    
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        Task {
            do {
                try await repo.send(conversationId: conversationId,
                                    senderId: currentUserId,
                                    text: text)
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }
    
    func stop() { listener = nil }
}

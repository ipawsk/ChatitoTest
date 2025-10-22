//
//  ConversationsViewModel.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import Foundation

final class ConversationsViewModel {
    struct Row: Hashable {
        let id: String
        let title: String
        let subtitle: String
        let time: String
    }

    var onUpdate: (([Row]) -> Void)?
    var onLoading: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    private let repo: ConversationRepository
    private let userId: String
    private var listenerToken: AnyObject?

    init(repo: ConversationRepository, userId: String) {
        self.repo = repo
        self.userId = userId
    }

    func start() {
        onLoading?(true)
        listenerToken = repo.observeMine(
            userId: userId,
            onChange: { [weak self] items in
                guard let self else { return }
                let df = DateFormatter()
                df.dateStyle = .short; df.timeStyle = .short

                let rows = items.map { c in
                    Row(
                        id: c.id,
                        title: c.title ?? "Conversación",
                        subtitle: c.lastMessageText ?? "—",
                        time: c.lastMessageAt.map { df.string(from: $0) } ?? ""
                    )
                }
                self.onUpdate?(rows)
                self.onLoading?(false)
            },
            onError: { [weak self] error in
                self?.onError?(error.localizedDescription)
                self?.onLoading?(false)
            }
        )
    }

    func stop() { listenerToken = nil }

    func conversationId(at index: Int, in rows: [Row]) -> String { rows[index].id }
    
    func createConversation(memberIds: [String], title: String?) async throws -> ConversationEntity {
        try await repo.create(memberIds: memberIds, title: title)
    }
}

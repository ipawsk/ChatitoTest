//
//  ConversationEntity.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import Foundation

struct ConversationEntity: Hashable {
    let id: String
    let title: String?
    let memberIds: [String]
    let lastMessageText: String?
    let lastMessageAt: Date?
    let updatedAt: Date
}

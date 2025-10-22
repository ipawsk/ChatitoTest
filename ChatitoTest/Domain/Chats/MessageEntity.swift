//
//  MessageEntity.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import Foundation

struct MessageEntity: Hashable {
    let id: String
    let senderId: String
    let username: String?
    let text: String
    let createdAt: Date
}

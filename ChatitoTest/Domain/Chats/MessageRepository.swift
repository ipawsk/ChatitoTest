//
//  MessageRepository.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import Foundation

protocol MessageRepository {
    @discardableResult
    func observe(conversationId: String,
                 onChange: @escaping ([MessageEntity]) -> Void,
                 onError: @escaping (Error) -> Void) -> AnyObject

    func send(conversationId: String,
              senderId: String,
              text: String) async throws
}

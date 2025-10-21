//
//  ConversationRepository.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import Foundation

protocol ConversationRepository {
    @discardableResult
    func observeMine(userId: String,
                     onChange: @escaping ([ConversationEntity]) -> Void,
                     onError: @escaping (Error) -> Void) -> AnyObject
    
    func create(memberIds: [String], title: String?) async throws -> ConversationEntity

}



//
//  Conversation.swift
//  Messenger
//
//  Created by Olena Stepaniuk on 11.11.2020.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}


struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

//
//  Nay8Mock.swift
//  Nay8Tests
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation
import Nay8Framework

// This is a mock implementation of a message sender that you can use in unit test
// Do not use this a real implementation.
class Nay8Mock: MessageSender {
    public var calls = [Message]()
    
    func send(_ body: String, to recipient: RecipientEntity?) {
        let me = Person(givenName: nil, handle: "", isMe: true)
        let message = Message(body: TextBody(body), date: Date(), sender: me, recipient: recipient!, attachments: [])
        send(message)
    }
    
    func send(_ message: Message) {
        calls.append(message)
    }
}

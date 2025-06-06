//
//  MessageSender.swift
//  Nay8
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation

public protocol MessageSender {
    func send(_ body: String, to recipient: RecipientEntity?)
    func send(_ message: Message)
}

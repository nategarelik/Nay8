//
//  Nay8.swift
//  Nay8Framework
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation
import Nay8Framework

public class Nay8: MessageSender {
    let queue = OperationQueue()
    
    init() {
        queue.maxConcurrentOperationCount = 1
    }
    
    public func send(_ body: String, to recipient: RecipientEntity?) {
        guard var recipient = recipient else {
            return
        }
        if let abstract = recipient as? AbstractRecipient {
            recipient = abstract.getSpecificEntity()
        }
        
        let me = Person(givenName: nil, handle: "", isMe: true)
        let message = Message(body: TextBody(body), date: Date(), sender: me, recipient: recipient, attachments: [])
        send(message)
    }
    
    public func send(_ message: Message) {
        NSLog("Attemping to send message: \(message)")
        
        let defaults = UserDefaults.standard
        
        //Don't send the message if Nay8 is currently disabled.
        guard !defaults.bool(forKey: Nay8Constants.nay8IsDisabled) else {
            return
        }
        
        let recipient = message.recipient.handle
        
        if let textBody = message.body as? TextBody {
            var scriptPath: String?
            let body = textBody.message
            
            if message.recipient.isGroupHandle() {
                scriptPath = Bundle.main.url(forResource: "SendText", withExtension: "scpt")?.path
            } else {
                scriptPath = Bundle.main.url(forResource: "SendTextSingleBuddy", withExtension: "scpt")?.path
            }
            
            queue.addOperation {
                self.executeScript(scriptPath: scriptPath, body: body, recipient: recipient)
            }
        }
        
        if let attachments = message.attachments {
            var scriptPath: String?
            
            if message.recipient.isGroupHandle() {
                scriptPath = Bundle.main.url(forResource: "SendImage", withExtension: "scpt")?.path
            } else {
                scriptPath = Bundle.main.url(forResource: "SendImageSingleBuddy", withExtension: "scpt")?.path
            }
            
            attachments.forEach{attachment in
                queue.addOperation {
                    self.executeScript(scriptPath: scriptPath, body: attachment.filePath, recipient: recipient)
                }
            }
        }
    }
    
    private func executeScript(scriptPath: String?, body: String?, recipient: String?) {
        guard(scriptPath != nil && body != nil && recipient != nil) else {
            return
        }
        
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptPath!, body!, recipient!]
        task.launch()
        task.waitUntilExit()
    }
}


//
//  Router.swift
//  Nay8
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation
import Nay8Framework

class Router : RouterDelegate {
    var pluginManager: PluginManagerDelegate
    var messageDelegates: [MessageDelegate]
    
    init(pluginManager: PluginManagerDelegate, messageDelegates: [MessageDelegate]) {
        self.pluginManager = pluginManager
        self.messageDelegates = messageDelegates
    }
    
    func route(message myMessage: Message) {
        // Notify message delegates first
        messageDelegates.forEach { delegate in delegate.didProcess(message: myMessage) }
        
        // Currently don't process any images
        guard let messageText = myMessage.body as? TextBody else {
            return
        }
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: messageText.message, options: [], range: NSMakeRange(0, messageText.message.count))
        let myLowercaseMessage = messageText.message.lowercased()
        
        let defaults = UserDefaults.standard
        
        guard !defaults.bool(forKey: Nay8Constants.nay8IsDisabled) || myLowercaseMessage == "/enable" else {
            return
        }
        
        // Check if message matches any routes
        var commandMatched = false
        RootLoop: for route in pluginManager.getAllRoutes() {
            guard (pluginManager.enabled(routeName: route.name)) else {
                continue
            }
            
            for comparison in route.comparisons {
                if comparison.0 == .containsURL {
                    for match in matches {
                        let url = (messageText.message as NSString).substring(with: match.range)
                        for comparisonString in comparison.1 {
                            if url.contains(comparisonString) {
                                let urlMessage = Message(body: TextBody(url), date: myMessage.date ?? Date(), sender: myMessage.sender, recipient: myMessage.recipient, attachments: [])
                                route.call(urlMessage)
                                commandMatched = true
                                break RootLoop // Exit early if we matched a URL route
                            }
                        }
                    }
                }
                
                else if comparison.0 == .startsWith {
                    for comparisonString in comparison.1 {
                        if myLowercaseMessage.hasPrefix(comparisonString.lowercased()) {
                            route.call(myMessage)
                            commandMatched = true
                            break RootLoop // Exit early if we matched a startWith route
                        }
                    }
                }
                
                else if comparison.0 == .contains {
                    for comparisonString in comparison.1 {
                        if myLowercaseMessage.contains(comparisonString.lowercased()) {
                            route.call(myMessage)
                            commandMatched = true
                            break RootLoop // Exit early if we matched a contains route
                        }
                    }
                }
                
                else if comparison.0 == .is {
                    for comparisonString in comparison.1 {
                        if myLowercaseMessage == comparisonString.lowercased() {
                            route.call(myMessage)
                            commandMatched = true
                            break RootLoop // Exit early if we matched an exact match route
                        }
                    }
                }
                else if comparison.0 == .isReaction {
                    if myMessage.action != nil {
                        route.call(myMessage)
                        commandMatched = true
                        break RootLoop // Exit early if we matched a reaction route
                    }
                }
            }
        }

        // If no route matched and it's not from the user, process with AIHandler
        if !commandMatched {
            if let senderPerson = myMessage.sender as? Person, !senderPerson.isMe {
                AIHandler.shared.processMessage(myMessage, using: pluginManager.getMessageSender())
            } else if !(myMessage.sender is Person) { // If sender is not a Person, assume not from me for AI processing
                AIHandler.shared.processMessage(myMessage, using: pluginManager.getMessageSender())
            }
        }
    }
}

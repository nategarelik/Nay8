//
//  main.swift
//  EmoteModule
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation
import Nay8Framework

public class EmoteModule: RoutingModule {
    var sender: MessageSender
    
    public var routes: [Route] = []
    public var description = "A Description"

    required public init(sender: MessageSender) {
        self.sender = sender
        
        let testRoute = Route(name: "test function", comparisons: [.startsWith: ["/moduletest"]], call: {[weak self] in self?.test(message: $0)}, description: "TEST")
        routes = [testRoute]
    }
    
    public func test(message: Message) -> Void {
        sender.send("This command was loaded from a modularized bundle.", to: message.RespondTo())
    }
}



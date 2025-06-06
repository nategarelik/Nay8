//
//  MockPluginManager.swift
//  Nay8Tests
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation
import Nay8Framework

let startWithString = "/startWith"
let containsString = "/contains"
let isString = "/is"



class MockRoute: RoutingModule {
    var sender: MessageSender
    var routes = [Route]()
    
    var description: String
    
    required public convenience init(sender: MessageSender) {
        self.init(sender: sender, description: "no description")
    }
    
    init(sender: MessageSender, description: String) {
        self.sender = sender
        self.description = description
    }
    
    func add(route: Route) {
        routes.append(route)
    }
}

class MockPluginManager: PluginManagerDelegate {
    var callCounts = [String: Int]()
    var disabled = [String: Bool]()
    var routingModules = [RoutingModule]()
    
    func getAllModules() -> [RoutingModule] {
        return routingModules
    }
    
    func add(module: RoutingModule) {
        routingModules.append(module)
    }

    func getAllRoutes() -> [Route] {
        return routingModules.flatMap { module in module.routes }
    }
    
    func reload() {
    }
    
    func enabled(routeName: String) -> Bool {
        return disabled[routeName, default: true]
    }
    
    func toggleDisable(routeName: String) -> Void {
        disabled[routeName] = !disabled[routeName, default: true]
    }
    
    func increment(routeName: String) -> Void {
        callCounts[routeName, default: 0] += 1
    }
}

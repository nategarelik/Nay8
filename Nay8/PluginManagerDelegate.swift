//
//  File.swift
//  Nay8
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation
import Nay8Framework

protocol PluginManagerDelegate {
    func getAllRoutes() -> [Route]
    func getAllModules() -> [RoutingModule]
    func reload()
    func enabled(routeName: String) -> Bool
    func getMessageSender() -> MessageSender
}

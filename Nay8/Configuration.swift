//
//  Configuration.swift
//  Nay8
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation

struct ConfigurationFile: Decodable {
    let routes: [String: RouteConfiguration]
    let webhooks: [Webhook]
    let webServer: WebserverConfiguration
    
    init() {
        routes = [:]
        webhooks = []
        webServer = WebserverConfiguration(port: 3000)
    }
}

struct WebserverConfiguration: Decodable {
    let port: Int
}

struct RouteConfiguration: Decodable {
    let disabled: Bool
}

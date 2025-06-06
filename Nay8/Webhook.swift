//
//  File.swift
//  Nay8
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation
import Nay8Framework

struct Webhook: Decodable {
    var url: String
    var routes: [Route]?
}

struct WebhookResponse: Decodable {
    var success: Bool
    var body: TextBody?
    var error: String?
}

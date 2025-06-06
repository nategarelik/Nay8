//
//  AutomationPermissionState.swift
//  Nay8
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation

enum AutomationPermissionState: Int {
    case declined
    case authorized
    case notDetermined
    case notRunning
    case unknown
}

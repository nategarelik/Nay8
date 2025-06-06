//
//  ActionType.swift
//  Nay8
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation

public enum ActionType: String {
    case like = "like"
    case dislike = "dislike"
    case love = "love"
    case laugh = "laugh"
    case exclaim = "exclaim"
    case question = "question"
    case unknown = "unknown"
    
    public init(fromActionTypeInt actionTypeInt: Int) {
        if let configurationMapping = Configuration.shared.parameters?.actionType[actionTypeInt] {
            self.init(rawValue: configurationMapping)!
        } else {
            self = .unknown
        }
    }
}

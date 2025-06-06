//
//  ActionTypeTest.swift
//  Nay8Tests
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import XCTest
import Nay8Framework

class ActionTypeTest: XCTestCase {
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testFromActionTypeInt() {
        XCTAssertEqual(ActionType(fromActionTypeInt: 2005), .question, "Properly deserializes known action type")
        
        XCTAssertEqual(ActionType(fromActionTypeInt: 696969), .unknown, "Properly deserializes unknown action type")
    }
}

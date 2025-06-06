//
//  ActionTest.swift
//  Nay8Tests
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import XCTest
import Nay8Framework

class ActionTest: XCTestCase {
    static let removeLikeJSON = "{\"type\":\"like\",\"targetGUID\":\"goodGUID\",\"event\":\"removed\"}"
    static let placeLoveJSON = "{\"type\":\"love\",\"targetGUID\":\"goodGUID\",\"event\":\"placed\"}"
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testFromActionTypeInt() {
        let targetGUID = "goodGUID"
        let encoder = JSONEncoder()
        var action = Action(actionTypeInt: 3001, targetGUID: targetGUID)
        
        XCTAssertEqual(action.event, .removed, "Event marked as removed")
        XCTAssertEqual(action.type, .like, "Type is correct")
        XCTAssertEqual(String(data: try! encoder.encode(action), encoding: .utf8),
                       ActionTest.removeLikeJSON, "Encoding works as expected")
        
        action = Action(actionTypeInt: 2000, targetGUID: targetGUID)
        
        XCTAssertEqual(action.event, .placed, "Event marked as removed")
        XCTAssertEqual(action.type, .love, "Type is correct")
        XCTAssertEqual(String(data: try! encoder.encode(action), encoding: .utf8),
                       ActionTest.placeLoveJSON, "Encoding works as expected")
    }
}

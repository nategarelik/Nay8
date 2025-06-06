//
//  GlobalTest.swift
//  Nay8Tests
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import XCTest
import Nay8Framework

class GlobalTest: XCTestCase {
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testFromActionTypeInt() {
        let anArray = [1, 2, 3, 4]
        
        let inBound = anArray[safe: 1]
        XCTAssertEqual(inBound, 2, "In bound property returns value")
        let outOfBounds = anArray[safe: 4]
        XCTAssertEqual(outOfBounds, nil, "Out of bounds array access returns nil")
    }
}

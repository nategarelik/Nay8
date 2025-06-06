//
//  SendStyleTest.swift
//  Nay8Tests
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import XCTest
import Nay8Framework

class SendStyleTest: XCTestCase {
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testFromSendStyleIdentifier() {
        XCTAssertEqual(SendStyle(fromIdentifier: nil), .regular, "Properly accept nil action type")
        
        XCTAssertEqual(SendStyle(fromIdentifier: "com.apple.messages.effect.CKShootingStarEffect"), .shootingStar, "Properly deserializes shooting star action type")
        
        XCTAssertEqual(SendStyle(fromIdentifier: "com.apple.MobileSMS.expressivesend.impact"), .slam, "Properly deserializes impact action type")
        
        XCTAssertEqual(SendStyle(fromIdentifier: "com.zeke.unknown"), .unknown, "Properly deserializes unknown action type")
    }
}

//
//  MessageTests.swift
//  Nay8Tests
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import XCTest
import Nay8Framework

class MessageTests: XCTestCase {
    let textBody = TextBody("Hey Nay8")
    
    let jaredPerson = Person(givenName: "jared", handle: "jared@email.com", isMe: false)
    let mePerson = Person(givenName: "zeke", handle: "zeke@email.com", isMe: true)
    let swiftPerson = Person(givenName: "taylor", handle: "taylor@swift.org", isMe: false)
    
    var sampleGroup: Group!
    
    var sampleTextMessage: Message!
    var messageFromMeToGroup: Message!
    var messageFromMeToPerson: Message!
    var messageFromPersonToGroup: Message!
    
    override func setUp() {
        sampleGroup = Group(name: "thank u next", handle: "chat1000", participants: [mePerson, jaredPerson, swiftPerson])
        
        sampleTextMessage = Message(body: textBody, date: Date(), sender: mePerson, recipient: jaredPerson)
        
        messageFromMeToGroup = Message(body: textBody, date: Date(), sender: mePerson, recipient: sampleGroup)
        messageFromPersonToGroup = Message(body: textBody, date: Date(), sender: swiftPerson, recipient: sampleGroup)
        messageFromMeToPerson = Message(body: textBody, date: Date(), sender: mePerson, recipient: swiftPerson)
    }
    
    override func tearDown() {
    }
    
    func testGetTextBody() {
        XCTAssertEqual(sampleTextMessage.getTextBody(), "Hey Nay8", "getTextBody returns proper string")
    }
    
    func testGetMessageResponse() {
        XCTAssertEqual(sampleTextMessage.RespondTo() as? Person, jaredPerson, "Message from me to person responds to recipient")
        XCTAssertEqual(messageFromMeToGroup.RespondTo() as? Group, sampleGroup, "Message from me to group responds to group")
        XCTAssertEqual(messageFromPersonToGroup.RespondTo() as? Group, sampleGroup, "Message from person to group responds to group")
        XCTAssertEqual(messageFromMeToPerson.RespondTo() as? Person, swiftPerson, "Message from me to person responds to person")
    }
}

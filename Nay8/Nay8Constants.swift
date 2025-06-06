//
//  Nay8Constants.swift
//  Nay8
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation

struct Nay8Constants {
    static let restApiIsDisabled = "RestApiIsDisabled"
    static let nay8IsDisabled = "Nay8IsDisabled"
    static let contactsAccess = "ContactsAccess"
    static let sendMessageAccess = "SendMessageAccess"
    static let fullDiskAccess = "FullDiskAccess"
    static let fullDiskAcccessUrl = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
    static let contactsAccessUrl = "x-apple.systempreferences:com.apple.preference.security?Privacy_Contacts"
    static let automationAccessUrl = "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation"
    static let messagesUrl = "messages://"
}

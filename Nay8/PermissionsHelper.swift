//
//  PermissionsHelper.swift
//  Nay8
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation
import Contacts

class PermissionsHelper {
    static func requestMessageAutomation() {
        let _ = canSendMessages(shouldPrompt: true)
    }
    
    static func canSendMessages(shouldPrompt: Bool = false) -> AutomationPermissionState {
        let target: NSAppleEventDescriptor
        if #available(OSX 11.0, *) {
            target = NSAppleEventDescriptor(bundleIdentifier: "com.apple.MobileSMS")
        } else {
            target = NSAppleEventDescriptor(bundleIdentifier: "com.apple.iChat")
        }
        if #available(OSX 10.14, *) {
            let permission = AEDeterminePermissionToAutomateTarget(target.aeDesc, typeWildCard, typeWildCard, shouldPrompt)
            var permissionEnum: AutomationPermissionState
            switch (permission) {
            case -1743:
                permissionEnum = .declined
            case -1744:
                permissionEnum = .notDetermined
            case 0:
                permissionEnum = .authorized
            case -600:
                permissionEnum = .notRunning
            default:
                permissionEnum = .unknown
            }
            
            UserDefaults.standard.set(permissionEnum.rawValue, forKey: Nay8Constants.sendMessageAccess)
            return permissionEnum
        } else {
            UserDefaults.standard.set(AutomationPermissionState.authorized.rawValue, forKey: Nay8Constants.sendMessageAccess)
            return .authorized
        }
    }
    
    static func getContactsStatus() -> CNAuthorizationStatus {
        let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        UserDefaults.standard.set(status.rawValue, forKey: Nay8Constants.contactsAccess)
        return status
    }
    
    static func requestContactsAccess() {
        if(CNContactStore.authorizationStatus(for: CNEntityType.contacts) == .notDetermined) {
            CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler: {enabled, _ in
                let _ = getContactsStatus()
            })
        }
    }
}

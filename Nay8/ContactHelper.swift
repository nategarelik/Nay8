//
//  ContactHelper.swift
//  Nay8
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation
import Contacts

class ContactHelper {
    static func RetreiveContact(handle: String) -> CNContact? {
        if (CNContactStore.authorizationStatus(for: CNEntityType.contacts) == .authorized) {
            let store = CNContactStore()
            
            let searchPredicate: NSPredicate
            
            if (!handle.contains("@")) {
                searchPredicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: handle))
            } else {
                searchPredicate = CNContact.predicateForContacts(matchingEmailAddress: handle)
            }
            
            let contacts = try! store.unifiedContacts(matching: searchPredicate, keysToFetch:[CNContactFamilyNameKey as CNKeyDescriptor,
                                                                                              CNContactGivenNameKey as CNKeyDescriptor,
                                                                                              CNContactEmailAddressesKey as CNKeyDescriptor,
                                                                                              CNContactPhoneNumbersKey as CNKeyDescriptor])
            if (contacts.count == 1) {
                return contacts[0]
            }
        }
        
        return nil
    }
}

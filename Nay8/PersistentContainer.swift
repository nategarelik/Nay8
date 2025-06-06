//
//  PersistentContainer.swift
//  
//
//  Copyright 2025 Nathaniel Garelik. All rights reserved.
//  Created by Nathaniel Garelik on 06/05/25.
//

import Foundation
import CoreData

class PersistentContainer: NSPersistentContainer, @unchecked Sendable {
    func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
        let context = backgroundContext ?? viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }
}

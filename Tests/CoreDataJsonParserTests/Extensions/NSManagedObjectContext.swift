//
//  NSManagedObjectContext.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    static var view: NSManagedObjectContext {
        NSPersistentContainer.container.viewContext
    }
    
}

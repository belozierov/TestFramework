//
//  XCTestCase.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import XCTest
import CoreData

extension XCTestCase {
    
    func performAndWaitOnViewContext(block: (NSManagedObjectContext) -> Void) {
        let context = NSManagedObjectContext.view
        context.performAndWait { block(context) }
    }
    
}

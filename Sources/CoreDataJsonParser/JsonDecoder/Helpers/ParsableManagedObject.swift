//
//  NSManagedObject+Configuration.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 8/13/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

public protocol ParsableManagedObject {}
extension NSManagedObject: ParsableManagedObject {}

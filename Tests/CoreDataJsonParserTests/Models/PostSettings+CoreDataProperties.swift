//
//  PostSettings+CoreDataProperties.swift
//  CoreDataJsonParserTests
//
//  Created by Alex Belozierov on 9/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//
//

import Foundation
import CoreData


extension PostSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostSettings> {
        return NSFetchRequest<PostSettings>(entityName: "PostSettings")
    }

    @NSManaged public var commenting: Bool
    @NSManaged public var postponePublication: Bool
    @NSManaged public var privacySettings: String?

}

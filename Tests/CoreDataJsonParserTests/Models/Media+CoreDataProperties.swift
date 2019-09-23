//
//  Media+CoreDataProperties.swift
//  CoreDataJsonParserTests
//
//  Created by Alex Belozierov on 9/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//
//

import Foundation
import CoreData


extension Media {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Media> {
        return NSFetchRequest<Media>(entityName: "Media")
    }

    @NSManaged public var advertised: Bool
    @NSManaged public var content: URL?
    @NSManaged public var createdDate: Date?
    @NSManaged public var fileType: String?
    @NSManaged public var id: String?
    @NSManaged public var isInFavorite: Bool
    @NSManaged public var lastModifiedDate: Date?
    @NSManaged public var order: Int16
    @NSManaged public var type: String?
    @NSManaged public var owner: Profile?

}

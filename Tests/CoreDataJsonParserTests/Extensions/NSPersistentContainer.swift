//
//  NSPersistentContainer.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/23/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

extension NSPersistentContainer {
    
    static let container: NSPersistentContainer = {
        ValueTransformer.registerIsoDateTransformer()
        let bundle = Bundle(for: JsonTests.self)
        let path = bundle.path(forResource: "TestDataModel", ofType: "momd")
        let url = path.map { URL(fileURLWithPath: $0) }
        let model = NSManagedObjectModel(contentsOf: url!)!
        let container = NSPersistentContainer(name: "CoreDataJsonParserTests4",
                                              managedObjectModel: model)
        container.loadPersistentStores { _, _ in }
        container.viewContext.undoManager = UndoManager()
        container.viewContext.performAndWait {
            Post.sharedJsonDecoder[\.createdDate].decodeStrategy =
                .valueTransformer(name: NSValueTransformerName(rawValue: "IsoDate"))
            Post.sharedJsonDecoder[\.lastModifiedDate].decodeStrategy = .isoDate
            Media.sharedJsonDecoder[\.createdDate].decodeStrategy = .isoDate
            Media.sharedJsonDecoder[\.lastModifiedDate].decodeStrategy = .isoDate
            Location.sharedJsonDecoder[\.details].jsonPath = .keyPath(\.description)
        }
        return container
    }()
    
}

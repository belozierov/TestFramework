//
//  NSPersistentContainer.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/23/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import XCTest
import CoreData
@testable import CoreDataJsonParser

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
//            Post.sharedJsonDecoder[\.createdDate].decodeStrategy = .isoDate
            Post.sharedJsonDecoder[\.lastModifiedDate].decodeStrategy = .isoDate
            Media.sharedJsonDecoder[\.createdDate].decodeStrategy = .isoDate
            Media.sharedJsonDecoder[\.lastModifiedDate].decodeStrategy = .isoDate
            Location.sharedJsonDecoder[\.details].jsonPath = .keyPath(\.description)
        }
        return container
    }()
    
}

extension NSManagedObjectContext {
    
    static var view: NSManagedObjectContext {
        NSPersistentContainer.container.viewContext
    }
    
}

extension XCTestCase {
    
    func performAndWaitOnViewContext(block: (NSManagedObjectContext) -> Void) {
        let context = NSManagedObjectContext.view
        context.performAndWait { block(context) }
    }
    
}

extension ValueTransformer {
    
    static func registerIsoDateTransformer() {
        let name = NSValueTransformerName(rawValue: "IsoDate")
        ValueTransformer.setValueTransformer(IsoDateValueTransformer(), forName: name)
    }
    
}

class IsoDateValueTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        (value as? String).flatMap(ISO8601DateFormatter.standart.date)
    }
    
}

extension ISO8601DateFormatter {
    
    static let standart: ISO8601DateFormatter = {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return isoFormatter
    }()
    
}

extension AttributeJsonDecoder.DecodeStrategy where Value == Date? {
    
    static let isoDate = AttributeJsonDecoder<Date?>.DecodeStrategy
        .custom { $0.transform(ISO8601DateFormatter.standart.date) }
    
}

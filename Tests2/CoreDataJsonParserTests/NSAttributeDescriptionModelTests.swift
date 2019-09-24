//
//  NSAttributeDescriptionModelTests.swift
//  CoreDataJsonParserTests
//
//  Created by Alex Belozierov on 9/23/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import XCTest
import CoreData
@testable import CoreDataJsonParser

class TestManagedObject: NSManagedObject {
    
    @NSManaged var string: String
    @NSManaged var string2: String?
    
}

class NSAttributeDescriptionModelTests: XCTestCase {
    
    func testAttributeDescriptionDefaultJsonDecoder() {
        let entity = NSEntityDescription()
        entity.managedObjectClassName = "TestManagedObject"

        let stringAttribute = NSAttributeDescription()
        stringAttribute.name = "string"
        stringAttribute.isOptional = false
        stringAttribute.attributeType = .stringAttributeType
        entity.properties.append(stringAttribute)

        if case .attribute(let model)? = stringAttribute.propertyModel?.property {
            XCTAssertEqual(try? Json(value: "Test").flatMap(model.decoder) as? String, "Test")
            do {
                _ = try Json(value: NSNull()).flatMap(model.decoder)
                XCTFail()
            } catch {}
        } else { XCTFail() }

        let optionalStringAttribute = NSAttributeDescription()
        optionalStringAttribute.name = "string2"
        optionalStringAttribute.isOptional = true
        optionalStringAttribute.attributeType = .stringAttributeType
        entity.properties.append(optionalStringAttribute)

        if case .attribute(let model)? = optionalStringAttribute.propertyModel?.property {
            XCTAssertEqual(try? Json(value: "Test").flatMap(model.decoder) as? String, "Test")
            XCTAssertNil(try Json(value: NSNull()).flatMap(model.decoder))
        } else { XCTFail() }
    }
    
}

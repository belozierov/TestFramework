//
//  EntityModelTests.swift
//  CoreDataJsonParserTests
//
//  Created by Alex Belozierov on 9/23/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import XCTest
import CoreData
@testable import CoreDataJsonParser

class EntityModelTests: XCTestCase {

    func testDefaultProperties() {
        performAndWaitOnViewContext { _ in
            let storage = JsonDecoderStorage()
            let model = EntityModel(entity: Profile.entity(), storage: storage)
            //string
            guard case .json(let decoder) = model["lastName"]?.decoder(with: storage) else { return XCTFail() }
            //positive
            let json = Json(value: ["lastName": "Test2"])!
            XCTAssertEqual(try? decoder(json) as? String, "Test2")
            //negative
            let json2 = Json(value: ["lastName": 123])!
            XCTAssertNil(try? decoder(json2) as? Int)
        }
    }
    
    func testCutsomProperties() {
        performAndWaitOnViewContext { _ in
            var profileModel = EntityModel(entity: Profile.entity(), storage: .init())
            let testAttribute: PropertyModel.Attribute = .decoder { _ in "Test" }
            profileModel["firstName"] = PropertyModel(property: .attribute(testAttribute), jsonPath: .root)
            let profileDecoder = EntityJsonDecoder(model: profileModel)
                    
            var mediaModel = EntityModel(entity: Media.entity(), storage: .init())
            let profileRelationModel = RelationModel(entity: Profile.entity(), relationType: .toOne,
                                                     deleteRule: .nullify, isOptional: true)
            let profileRelation = PropertyModel.Relation(entityDecoder: .decoder(profileDecoder),
                                                         relationModel: profileRelationModel)
            mediaModel["owner"] = PropertyModel(property: .relation(profileRelation), jsonPath: .root)
            
            switch mediaModel["owner.firstName"]?.decoder(with: mediaModel.storage) {
            case .json(let decoder):
                XCTAssertEqual(try? decoder(.test) as? String, "Test")
            default:
                XCTFail()
            }
            
            switch mediaModel["owner.lastName"]?.decoder(with: mediaModel.storage) {
            case .json(let decoder):
                let json = Json(value: ["lastName": "Test2"])!
                XCTAssertEqual(try? decoder(json) as? String, "Test2")
            default:
                XCTFail()
            }
        }
    }
    
}

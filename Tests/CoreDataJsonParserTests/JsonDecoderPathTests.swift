//
//  JsonDecoderPathTests.swift
//  CoreDataJsonParserTests
//
//  Created by Alex Belozierov on 9/23/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import XCTest
import CoreData
@testable import CoreDataJsonParser

class JsonDecoderPathTests: XCTestCase {
    
    let json = Json.test[0]!
    
    func testByKeyTransform() {
        let path = JsonDecoderPath.key(path: "owner.firstName")
        XCTAssertEqual(try path.transform(json)?.convert() as String?, json.owner?.firstName)
    }
    
    func testByKeyPathTransform() {
        let path = JsonDecoderPath.keyPath(\.owner?.firstName)
        XCTAssertEqual(try path.transform(json)?.convert() as String?, json.owner?.firstName)
    }
    
    func testByCustomTransform() {
        let path = JsonDecoderPath.custom { $0.owner?.firstName }
        XCTAssertEqual(try path.transform(json)?.convert() as String?, json.owner?.firstName)
    }
    
    func testByRootTransform() {
        let rootJson = json.owner!.firstName!
        let path = JsonDecoderPath.root
        XCTAssertEqual(try path.transform(rootJson)?.convert() as String?, rootJson.convert())
    }
    
}

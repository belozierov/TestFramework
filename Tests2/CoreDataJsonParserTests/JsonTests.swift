//
//  JsonTests.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 8/12/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import XCTest
@testable import CoreDataJsonParser

class JsonTests: XCTestCase {
    
    lazy var data = jsonString.data(using: .utf8)!
    
    func testJsonConvertable() {
        //Dictionary
        XCTAssertEqual(Json(value: ["1": 1]).flatMap(Dictionary.init), ["1": 1])
        XCTAssertNil(Json(value: 1).flatMap(Dictionary<String, Int>.init))
        //Array
        XCTAssertEqual(Json(value: [1, 2]).flatMap(Array.init), [1, 2])
        XCTAssertNil(Json(value: ["1": 1]).flatMap(Array<Int>.init))
        //String
        XCTAssertEqual(Json(value: "string").flatMap(String.init), "string")
        XCTAssertNil(Json(value: [1]).flatMap(String.init))
        //JsonNumberConvertible
        XCTAssertEqual(Json(value: 100).flatMap(Int.init), 100)
        XCTAssertEqual(Json(value: "100").flatMap(Int.init), 100)
        XCTAssertNil(Json(value: ["": 0]).flatMap(Int.init))
        XCTAssertEqual(Json(value: false).flatMap(Bool.init), false)
        XCTAssertEqual(Json(value: 1).flatMap(Double.init), 1)
        //URL
        XCTAssertNil(Json(value: [1]).flatMap(URL.init))
        XCTAssertNil(Json(value: "\test").flatMap(URL.init))
        XCTAssertEqual(Json(value: "https://www.google.com").flatMap(URL.init),
                       URL(string: "https://www.google.com"))
    }
    
    func testJsonInit() {
        XCTAssertNotNil(Json(data: data))
        XCTAssertNil(",test".data(using: .utf8).flatMap { Json(data: $0) })
        XCTAssertNil(",test".data(using: .utf8).flatMap { Json(value: $0) })
        XCTAssertEqual(Json(value: "string")?.convert(), "string")
        XCTAssertEqual(Json(value: 100)?.convert(), 100)
        XCTAssertEqual(Json(value: true)?.convert(), true)
    }
    
    func testJsonParsing() {
        let json = Json(data: data)
        
        //test subscription
        let dict = json?.dict1?.dict2
        XCTAssertEqual(dict?.string, "Test string")
        XCTAssertEqual(dict?.int, 100)
        XCTAssertEqual(dict?.int, 100.0)
        XCTAssertEqual(dict?.int, "100")
        XCTAssertEqual(dict?.false, false)
        XCTAssertEqual(dict?.false, 0)
        XCTAssertEqual(dict?.true, true)
        XCTAssertEqual(dict?.true, 1)
        XCTAssertNotNil(dict["true"])
        XCTAssertEqual(dict["true"], true)
        XCTAssertEqual(dict?.arr, ["1", "2"])
        XCTAssertEqual(dict?.arr?[0], "1")
        XCTAssertEqual(dict?.arr[0], "1")
        XCTAssertNil(dict?.arr?[2])
        XCTAssertNil(dict?.arr[2])
        XCTAssertNil(dict?.arr?.test)
        XCTAssertEqual(json?.url, URL(string: "https://www.google.com"))
        XCTAssertNil(json?.someJson)
        
        //test transform
        XCTAssertEqual(dict?.int?.transform { $0 + 1 }, 101)
        XCTAssertNil(dict?.int?.transform { $0 <= 100 ? nil : $0 })
        
        //test any
        XCTAssertTrue(dict?.any is [String: Any])
        XCTAssertTrue(dict?.int?.any is Int)
        XCTAssertTrue(dict?.int?.any is Double)
        XCTAssertFalse(dict?.int?.any is String)
        XCTAssertTrue(dict?.true?.any is Bool)
        XCTAssertTrue(dict?.arr?.any is [Any])
        XCTAssertTrue(json?.url?.any is String)
        XCTAssertTrue(json?.null?.any is NSNull)
        
        //tetst array fail
        XCTAssertNil(json?.array)
    }
    
    func testJsonOperators() {
        //optional
        var optional: Int?
        optional <- Json(value: "1")
        XCTAssertEqual(optional, 1)
        try? optional <~ Json(value: "2")
        XCTAssertEqual(optional, 2)
        try? optional <~ Json(value: "a")
        XCTAssertEqual(optional, 2)
        let nilValue: Int? = nil
        optional <- nilValue
        XCTAssertEqual(optional, 2)
        try? optional <~ nilValue
        XCTAssertEqual(optional, 2)
        let optionalValue: Int? = 3
        optional <- optionalValue
        XCTAssertEqual(optional, 3)
        //not optional
        var notOptional = 0
        notOptional <- Json(value: "1")
        XCTAssertEqual(notOptional, 1)
        try? notOptional <~ Json(value: "2")
        XCTAssertEqual(notOptional, 2)
        try? notOptional <~ Json(value: "a")
        XCTAssertEqual(notOptional, 2)
    }
    
    func testDateJson() {
        let isoString = ISO8601DateFormatter().string(from: Date())
        let testDate = ISO8601DateFormatter().date(from: isoString)!
        XCTAssertEqual(Json(value: testDate.timeIntervalSince1970)?.convert(), testDate)
        XCTAssertEqual(Json(value: isoString)?.convert(), testDate)
        XCTAssertNil(Json(value: "Test")?.convert() as Date?)
        XCTAssertNil(Json(value: "Test")?.convert() as Date?)
        XCTAssertNil(Json(value: ["Test"])?.convert() as Date?)
    }
    
    func testUUIDJson() {
        let uuid = UUID()
        XCTAssertEqual(Json(value: uuid.uuidString)?.convert(), uuid)
        XCTAssertNil(Json(value: "UUID")?.convert() as UUID?)
        XCTAssertNil(Json(value: 123)?.convert() as UUID?)
    }
    
}

private let jsonString =
#"""
{
    "dict1": {
        "dict2": {
            "string": "Test string",
            "int": 100,
            "false": 0,
            "true": true,
            "arr": ["1", "2"]
        }
    },
    "url": "https://www.google.com",
    "null": null,
    "seconds": 1406662283.764424
}
"""#

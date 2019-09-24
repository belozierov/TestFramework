//
//  TestJson.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/23/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import XCTest
@testable import CoreDataJsonParser

extension Json {
    
    static let test: Json = {
        let bundle = Bundle(for: JsonTests.self)
        let path = bundle.path(forResource: "ParseModel", ofType: "json")
        let url = path.map { URL(fileURLWithPath: $0) }
        let data = try! Data(contentsOf: url!)
        return Json(data: data)!
    }()
    
}

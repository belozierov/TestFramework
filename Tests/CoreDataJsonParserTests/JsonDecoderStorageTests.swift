//
//  JsonDecoderStorageTests.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/23/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import XCTest
import CoreData
@testable import CoreDataJsonParser

class JsonDecoderStorageTests: XCTestCase {
    
    private lazy var postJson = Json.test.array![0]
    
    func testBaseStorageChanges() {
        performAndWaitOnViewContext { context in
            var storage = JsonDecoderStorage()
            storage[\Profile.firstName].decodeStrategy = .custom { _ in "Test1" }
                        
            var profileDecoder = ManagedObjectJsonDecoder<Profile>()
            profileDecoder[\.firstName].decodeStrategy = .custom { _ in "Test3" }
            storage[\Media.owner].decoder = profileDecoder
                        
            let storage2 = storage
            storage[\Post.owner?.firstName].decodeStrategy = .custom { _ in "Test2" }
            
            let post1 = try? storage.decode(of: Post.self, json: postJson, context: context)
            XCTAssertEqual(post1?.owner?.firstName, "Test2")
            XCTAssertEqual(post1?.recipient?.firstName, "Test1")
            XCTAssertEqual((post1?.media?.allObjects as? [Media])?.first?.owner?.firstName, "Test3")
            
            let post2 = try? storage2.decode(of: Post.self, json: postJson, context: context)
            XCTAssertEqual(post2?.owner?.firstName, "Test1")
            XCTAssertEqual(post2?.recipient?.firstName, "Test1")
            XCTAssertEqual((post2?.media?.allObjects as? [Media])?.first?.owner?.firstName, "Test3")
        }
    }
    
    func testNestedStorageChanges() {
        performAndWaitOnViewContext { context in
            var storage = JsonDecoderStorage()
            storage[\Profile.firstName].decodeStrategy = .custom { _ in "Test1" }
                    
            var profileDecoder = ManagedObjectJsonDecoder<Profile>()
            profileDecoder[\.firstName].decodeStrategy = .custom { _ in "Test3" }
                    
            var mediaDecoder = ManagedObjectJsonDecoder<Media>()
            mediaDecoder[\.owner].decoder = profileDecoder
            storage[\Post.media, type: Media.self].decoder = mediaDecoder
            
            let post = try? storage.decode(of: Post.self, json: postJson, context: context)
            XCTAssertEqual(post?.owner?.firstName, "Test1")
            XCTAssertEqual(post?.recipient?.firstName, "Test1")
            XCTAssertEqual((post?.media?.allObjects as? [Media])?.first?.owner?.firstName, "Test3")
        }
    }
    
}


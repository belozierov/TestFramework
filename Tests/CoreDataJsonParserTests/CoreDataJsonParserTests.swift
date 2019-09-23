//
//  CoreDataJsonParserTests.swift
//  CoreDataJsonParserTests
//
//  Created by Alex Belozierov on 8/12/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import XCTest
import CoreData
@testable import CoreDataJsonParser

class CoreDataJsonParserTests: XCTestCase {
    
    func testExample() {
        let json = Json.test
        performAndWaitOnViewContext { context in
            do {
                let start = Date()
                let posts = try json.decode(type: [Post].self, context: context)
                print("TIME", Date().timeIntervalSince(start))
                XCTAssertEqual(posts.count, json.array?.count)
                //test post parse
                let post = posts[0]
                let postJson = json.array?.first
                XCTAssertEqual(post.body, postJson?.body)
                XCTAssertEqual(post.commentsCount, postJson?.commentsCount)
                //            XCTAssertEqual(post.createdDate, postJson?.createdDate.map(isoFormatter.date))
                XCTAssertEqual(post.id, postJson?.id)
                XCTAssertEqual(post.isAdvertisable, postJson?.isAdvertisable)
                XCTAssertEqual(post.isAdvertised, postJson?.isAdvertised)
                XCTAssertEqual(post.isContentUnavailable, postJson?.isContentUnavailable)
                XCTAssertEqual(post.isLiked, postJson?.isLiked)
//                XCTAssertEqual(post.lastModifiedDate, postJson?.lastModifiedDate.map(isoFormatter.date))
                XCTAssertEqual(post.reactionsCount, postJson?.reactionsCount)
                XCTAssertEqual(post.sharesCount, postJson?.sharesCount)
                //test media parse
                guard let media = (post.media?.allObjects as? [Media])?.first,
                    let mediaJson = postJson?.media?[0] else { return XCTFail() }
                XCTAssertEqual(media.advertised, mediaJson.advertised)
                XCTAssertEqual(media.content, mediaJson.content)
                //            XCTAssertEqual(media.createdDate, mediaJson.lastModifiedDate.map(isoFormatter.date))
                XCTAssertEqual(media.fileType, mediaJson.fileType)
                XCTAssertEqual(media.id, mediaJson.id)
                XCTAssertEqual(media.isInFavorite, mediaJson.isInFavorite)
                //            XCTAssertEqual(media.lastModifiedDate, mediaJson.lastModifiedDate.map(isoFormatter.date))
                XCTAssertEqual(media.order, mediaJson.order)
                XCTAssertEqual(media.type, mediaJson.type)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        
        //        let json2 = Json(value: 1)
        //        XCTAssertNil(try? json2?.parse(of: [Post].self, in: container.viewContext))
        //        XCTAssertNil(try? json2?.parse(of: Post.self, in: container.viewContext))
    }
    
//    func testNegativeCases() {
//        let json = Json(value: 1)
//        XCTAssertNil(try? json?.decode(type: [Post].self, context: .view))
//        XCTAssertNil(try? json?.decode(type: Post.self, context: .view))
//    }

}




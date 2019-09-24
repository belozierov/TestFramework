//
//  EntityJsonDecoderTests.swift
//  CoreDataJsonParserTests
//
//  Created by Alex Belozierov on 9/23/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import XCTest
import CoreData
@testable import CoreDataJsonParser

class EntityJsonDecoderTests: XCTestCase {
    
    func testJsonDecodersFuncs() {
        let json = Json.test[0]!.media[0]!
        performAndWaitOnViewContext { context in
            var decoder = Media.sharedJsonDecoder.entityDecoder
            do {
                let media = try json.decode(type: Media.self, context: context)
                let media2 = try decoder.findObject(json: json, context: context)
                XCTAssertEqual(media, media2)
                let media3 = try decoder.create(json: json, context: context)
                context.delete(media3)
                XCTAssertNotEqual(media, media3)
                let predicate = try decoder.predicate(json: json)!
                let media4 = try decoder.findObject(predicate: predicate, context: context)
                XCTAssertEqual(media, media4)
                let media5 = try decoder.parse(json: json, context: context, predicate: predicate)
                XCTAssertEqual(media, media5)
                decoder.entityModel.findObjectStrategy = .predicate { _ in
                    NSPredicate(format: "SELF = %@", media)
                }
                let media6 = try decoder.findObject(json: json, context: context)
                XCTAssertEqual(media, media6)
                decoder.entityModel.findObjectStrategy = .none
                XCTAssertNil(try decoder.findObject(json: json, context: context))
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testJsonParsing() {
        let json = Json.test
        let isoFormatter = ISO8601DateFormatter.standart
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
            XCTAssertEqual(post.createdDate, postJson?.createdDate.map(isoFormatter.date))
            XCTAssertEqual(post.id, postJson?.id)
            XCTAssertEqual(post.isAdvertisable, postJson?.isAdvertisable)
            XCTAssertEqual(post.isAdvertised, postJson?.isAdvertised)
            XCTAssertEqual(post.isContentUnavailable, postJson?.isContentUnavailable)
            XCTAssertEqual(post.isLiked, postJson?.isLiked)
            XCTAssertEqual(post.lastModifiedDate, postJson?.lastModifiedDate.map(isoFormatter.date))
            XCTAssertEqual(post.reactionsCount, postJson?.reactionsCount)
            XCTAssertEqual(post.sharesCount, postJson?.sharesCount)
            //test media parse
            let media = (post.media?.allObjects as? [Media])![0]
            let mediaJson = postJson!.media![0]!
            XCTAssertEqual(media.advertised, mediaJson.advertised)
            XCTAssertEqual(media.content, mediaJson.content)
            XCTAssertEqual(media.createdDate, mediaJson.lastModifiedDate.map(isoFormatter.date))
            XCTAssertEqual(media.fileType, mediaJson.fileType)
            XCTAssertEqual(media.id, mediaJson.id)
            XCTAssertEqual(media.isInFavorite, mediaJson.isInFavorite)
            XCTAssertEqual(media.lastModifiedDate, mediaJson.lastModifiedDate.map(isoFormatter.date))
            XCTAssertEqual(media.order, mediaJson.order)
            XCTAssertEqual(media.type, mediaJson.type)
            
            let mediaOwner = media.owner
            let mediaOwnerJson = mediaJson.owner!
            XCTAssertEqual(mediaOwner?.uuid, mediaOwnerJson.uuid)
            XCTAssertEqual(mediaOwner?.firstName, mediaOwnerJson.firstName)
            XCTAssertEqual(mediaOwner?.lastName, mediaOwnerJson.lastName)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testDisableProperties() {
        performAndWaitOnViewContext { context in
            var decoder = ManagedObjectJsonDecoder<Post>()
            guard case .shared = decoder[\.owner?.firstName].decodeStrategy,
                case .shared = decoder[\.owner].decodeStrategy else { return XCTFail() }
            decoder[\.owner?.firstName].decodeStrategy = .disable
            guard case .disable = decoder[\.owner?.firstName].decodeStrategy
                else { return XCTFail() }
            let json = Json.test[0]!
            do {
                let post = try decoder.decodeObject(json: json, context: context)
                let owner = post.owner
                XCTAssertNil(owner?.firstName)
                XCTAssertEqual(owner?.lastName, json.owner?.lastName)
                XCTAssertEqual(owner?.uuid, json.owner?.uuid)
                XCTAssertNotNil(decoder[\.owner].decoder)
            } catch {
                XCTFail(error.localizedDescription)
            }
            (try? decoder.entityDecoder.findObject(json: json, context: context) as? Post)?.owner = nil
            do {
                decoder[\.owner].decodeStrategy = .disable
                XCTAssertNil(decoder[\.owner].decoder)
                let post = try decoder.decodeObject(json: json, context: context)
                XCTAssertNil(post.owner)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
}

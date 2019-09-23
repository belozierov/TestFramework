//
//  Post+CoreDataProperties.swift
//  CoreDataJsonParserTests
//
//  Created by Alex Belozierov on 9/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//
//

import Foundation
import CoreData


extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post")
    }

    @NSManaged public var body: String?
    @NSManaged public var commentsCount: Int64
    @NSManaged public var createdDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var isAdvertisable: Bool
    @NSManaged public var isAdvertised: Bool
    @NSManaged public var isContentUnavailable: Bool
    @NSManaged public var isLiked: Bool
    @NSManaged public var lastModifiedDate: Date?
    @NSManaged public var reactionsCount: Int64
    @NSManaged public var sharesCount: Int64
    @NSManaged public var location: Location?
    @NSManaged public var media: NSSet?
    @NSManaged public var originPost: Post?
    @NSManaged public var owner: Profile?
    @NSManaged public var recipient: Profile?
    @NSManaged public var settings: PostSettings?
    @NSManaged public var taggedFriends: NSSet?

}

// MARK: Generated accessors for media
extension Post {

    @objc(addMediaObject:)
    @NSManaged public func addToMedia(_ value: Media)

    @objc(removeMediaObject:)
    @NSManaged public func removeFromMedia(_ value: Media)

    @objc(addMedia:)
    @NSManaged public func addToMedia(_ values: NSSet)

    @objc(removeMedia:)
    @NSManaged public func removeFromMedia(_ values: NSSet)

}

// MARK: Generated accessors for taggedFriends
extension Post {

    @objc(addTaggedFriendsObject:)
    @NSManaged public func addToTaggedFriends(_ value: Profile)

    @objc(removeTaggedFriendsObject:)
    @NSManaged public func removeFromTaggedFriends(_ value: Profile)

    @objc(addTaggedFriends:)
    @NSManaged public func addToTaggedFriends(_ values: NSSet)

    @objc(removeTaggedFriends:)
    @NSManaged public func removeFromTaggedFriends(_ values: NSSet)

}

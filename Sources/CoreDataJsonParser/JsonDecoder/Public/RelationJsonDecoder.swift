//
//  RelationJsonDecoder.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/6/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

public protocol RelationJsonDecodable {}
extension NSSet: RelationJsonDecodable {}
extension NSOrderedSet: RelationJsonDecodable {}
extension Optional: RelationJsonDecodable where Wrapped: RelationJsonDecodable {}

public struct RelationJsonDecoder<Object: NSManagedObject> {
    
    public enum DecodeStrategy {
        case shared
        case custom(decoder: ManagedObjectJsonDecoder<Object>)
        case disable
    }
    
    public var jsonPath: JsonDecoderPath, decodeStrategy: DecodeStrategy
    
    init(propertyModel: PropertyModel) {
        jsonPath = propertyModel.jsonPath!
        switch propertyModel.property {
        case .attribute: fatalError()
        case .relation(let relation):
            switch relation.entityDecoder {
            case .storage:
                decodeStrategy = .shared
            case .decoder(let entityDecoder):
                decodeStrategy = .custom(decoder: .init(entityDecoder: entityDecoder))
            }
        case .disable:
            decodeStrategy = .disable
        case nil:
            decodeStrategy = .shared
        }
    }
    
    public var decoder: ManagedObjectJsonDecoder<Object>? {
        set { decodeStrategy = newValue.map { .custom(decoder: $0) } ?? .disable }
        get {
            switch decodeStrategy {
            case .shared: return Object.sharedJsonDecoder
            case .custom(let decoder): return decoder
            case .disable: return nil
            }
        }
    }
    
}

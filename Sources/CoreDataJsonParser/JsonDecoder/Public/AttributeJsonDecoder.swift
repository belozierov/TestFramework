//
//  AttributeJsonDecoder.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/6/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

public struct AttributeJsonDecoder<Value> {
    
    public enum DecodeStrategy {
        case shared
        case custom(decoder: (Json) throws -> Value?)
        case valueTransformer(name: NSValueTransformerName)
        case disable
    }
    
    public var jsonPath: JsonDecoderPath, decodeStrategy: DecodeStrategy
    
    init(propertyModel: PropertyModel) {
        jsonPath = propertyModel.jsonPath!
        switch propertyModel.property {
        case .attribute(let attribute):
            switch attribute {
            case .model:
                decodeStrategy = .shared
            case .decoder(let decoder):
                decodeStrategy = .custom { try decoder($0) as? Value }
            case .valueTransformer(let name):
                decodeStrategy = .valueTransformer(name: name)
            }
        case .relation:
            fatalError()
        case .disable:
            decodeStrategy = .disable
        case nil:
            decodeStrategy = .shared
        }
    }
    
}

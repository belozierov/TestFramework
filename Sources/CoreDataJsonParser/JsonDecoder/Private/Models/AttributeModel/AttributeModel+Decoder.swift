//
//  AttributeModel+Decoder.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/8/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

extension AttributeModel {
    
    var decoder: (Json) throws -> Any? {
        if isOptional { return attributeDecoder }
        let decoder = attributeDecoder
        return { json in
            if let value = try decoder(json) { return value }
            throw ParseError.nullResultInNotOptionalProperty
        }
    }
    
    private var attributeDecoder: (Json) throws -> Any? {
        switch attributeType {
        case .string: return String.init
        case .int16: return Int16.init
        case .int32: return Int32.init
        case .int64: return Int64.init
        case .float: return Float.init
        case .double: return Double.init
        case .bool: return Bool.init
        case .date: return Date.init
        case .url: return URL.init
        case .uuid: return UUID.init
        }
    }
    
}

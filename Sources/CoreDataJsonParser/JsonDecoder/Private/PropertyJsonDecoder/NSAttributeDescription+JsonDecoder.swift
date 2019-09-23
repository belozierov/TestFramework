//
//  NSAttributeDescription+JsonDecoder.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/7/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

extension NSAttributeDescription {
    
    var propertyModel: PropertyModel? {
        guard let attribute = propertyModelAttribute else { return nil }
        return PropertyModel(property: .attribute(attribute), jsonPath: jsonPath)
    }
    
    var propertyModelAttribute: PropertyModel.Attribute? {
        if let name = userInfo?["jsonParser"] as? String {
            return .valueTransformer(NSValueTransformerName(name))
        } else if let model = attributeModel {
            return .model(model)
        }
        return nil
    }
    
    var attributeModel: AttributeModel? {
        guard let type = modelAttributeType else { return nil }
        return AttributeModel(attributeType: type, isOptional: isOptional)
    }
    
    // MARK: - Default ValueParser
    
    private var modelAttributeType: AttributeModel.AttributeType? {
        switch attributeType {
        case .stringAttributeType: return .string
        case .integer16AttributeType: return .int16
        case .integer32AttributeType: return .int32
        case .integer64AttributeType: return .int64
        case .floatAttributeType: return .float
        case .doubleAttributeType: return .double
        case .booleanAttributeType: return .bool
        case .dateAttributeType: return .date
        case .URIAttributeType: return .url
        case .UUIDAttributeType: return .uuid
        default: return nil
        }
    }
    
}


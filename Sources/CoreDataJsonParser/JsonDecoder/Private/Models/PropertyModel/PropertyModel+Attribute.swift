//
//  PropertyModel+Attribute.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/8/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

extension PropertyModel {
    
    enum Attribute {
        case model(AttributeModel)
        case decoder((Json) throws -> Any?)
        case valueTransformer(NSValueTransformerName)
    }
    
}

extension PropertyModel.Attribute {
    
    var decoder: (Json) throws -> Any? {
        switch self {
        case .model(let model):
            return model.decoder
        case .decoder(let decoder):
            return decoder
        case .valueTransformer(let name):
            return name.decode
        }
    }
    
}

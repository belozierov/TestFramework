//
//  AttributeModel.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/7/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

struct AttributeModel {
    
    enum AttributeType {
        case string
        case int16, int32, int64
        case float, double
        case bool
        case date
        case url
        case uuid
    }
    
    let attributeType: AttributeType
    let isOptional: Bool
    
}

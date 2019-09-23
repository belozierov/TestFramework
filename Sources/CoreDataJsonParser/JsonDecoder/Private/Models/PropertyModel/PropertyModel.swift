//
//  PropertyModel.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/8/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

struct PropertyModel {
    
    var property: Property?
    var jsonPath: JsonDecoderPath?
    
    func updated(with changes: PropertyModel) -> PropertyModel {
        var model = self
        changes.property.map { model.property = $0 }
        changes.jsonPath.map { model.jsonPath = $0 }
        return model
    }
    
    mutating func updateStorage(_ updater: (inout JsonDecoderStorage) -> Void) {
        guard case .relation(var relation) = property,
            case .decoder(var decoder) = relation.entityDecoder else { return }
        decoder.entityModel.updateStorage(updater)
        relation.entityDecoder = .decoder(decoder)
        property = .relation(relation)
    }
    
}

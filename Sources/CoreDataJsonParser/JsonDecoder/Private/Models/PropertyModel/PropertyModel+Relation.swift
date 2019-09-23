//
//  PropertyModel+Relation.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/8/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

extension PropertyModel {
    
    struct Relation {
        var entityDecoder: EntityDecoder
        var relationModel: RelationModel
    }
    
}

extension PropertyModel.Relation {
    
    enum EntityDecoder {
        case storage
        case decoder(EntityJsonDecoder)
    }
    
    func decoder(with storage: JsonDecoderStorage) -> PropertyModel.Decoder<Any?> {
        switch entityDecoder {
        case .decoder(let decoder):
            return relationModel.jsonDecoder(decoder: decoder)
        case .storage:
            let decoder = storage[relationModel.entity]
            return relationModel.jsonDecoder(decoder: decoder)
        }
    }
    
}

//
//  PropertyModel+Property.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/8/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

extension PropertyModel {
    
    enum Property {
        case relation(Relation)
        case attribute(Attribute)
        case disable
    }
    
}

extension PropertyModel.Property {
    
    func entityDecoder(with storage: JsonDecoderStorage) -> EntityJsonDecoder? {
        guard case .relation(let relation) = self else { return nil }
        switch relation.entityDecoder {
        case .storage: return storage[relation.relationModel.entity]
        case .decoder(let decoder): return decoder
        }
    }
    
    mutating func setEntityDecoder(_ decoder: EntityJsonDecoder) {
        guard case .relation(var relation) = self else { return }
        relation.entityDecoder = .decoder(decoder)
        self = .relation(relation)
    }
    
    func decoder(with storage: JsonDecoderStorage) -> PropertyModel.Decoder<Any?>? {
        switch self {
        case .attribute(let attribute):
            return .json(attribute.decoder)
        case .relation(let relation):
            return relation.decoder(with: storage)
        case .disable:
            return nil
        }
    }
    
}

//
//  PropertyModel+Decoder.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/8/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

extension PropertyModel {
    
    enum Decoder<T> {
        case json((Json) throws -> T)
        case context((Json, NSManagedObjectContext?) throws -> T)
        case oldValue((Json, T, NSManagedObjectContext?) throws -> T)
    }
    
    func decoder(with storage: JsonDecoderStorage) -> Decoder<Any??>? {
        guard let jsonTransformer = jsonPath?.transform else { return nil }
        switch property?.decoder(with: storage) {
        case .json(let decoder):
            return .json { json in
                try jsonTransformer(json).map(decoder)
            }
        case .context(let decoder):
            return .context { json, context in
                try jsonTransformer(json).map { try decoder($0, context) }
            }
        case .oldValue(let decoder):
            return .oldValue { json, oldValue, context in
                try jsonTransformer(json).map { try decoder($0, oldValue as Any?, context) }
            }
        case nil:
            return nil
        }
    }
    
}


//
//  _JsonDecoderStorage.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/20/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

class _JsonDecoderStorage {
    
    static let empty = _JsonDecoderStorage(decoders: [:])
    
    private static let nextVersion: () -> Int = {
        var version = 0
        return {
            defer { version += 1 }
            return version
        }
    }()
    
    let version: Int
    var decoders: [NSEntityDescription: EntityJsonDecoder]
    
    init(decoders: [NSEntityDescription: EntityJsonDecoder]) {
        self.decoders = decoders
        version = _JsonDecoderStorage.nextVersion()
    }
    
}

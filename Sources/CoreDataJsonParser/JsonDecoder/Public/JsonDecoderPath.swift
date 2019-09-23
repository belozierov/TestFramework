//
//  JsonDecoderPath.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/9/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

public enum JsonDecoderPath {
    case key(path: String)
    case keyPath(KeyPath<Json, Json?>)
    case custom((Json) throws -> Json?)
    case root
}

extension JsonDecoderPath {
    
    var transform: (Json) throws -> Json? {
        switch self {
        case .keyPath(let keyPath):
            return { $0[keyPath: keyPath] }
        case .key(let path):
            let paths = path.components(separatedBy: ".")
            if paths.count == 1, let key = paths.first { return { $0[key] } }
            return { json in
                var json: Json? = json
                for key in paths { json = json?[key] }
                return json
            }
        case .custom(let transform):
            return transform
        case .root:
            return { $0 }
        }
    }
    
}

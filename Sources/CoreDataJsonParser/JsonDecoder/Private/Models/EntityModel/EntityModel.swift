//
//  EntityModel.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/8/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

struct EntityModel {
    
    enum FindObjectStrategy {
        case byConstraints([[String]])
        case predicate((Json) throws -> NSPredicate)
        case none
    }
    
    struct Changes {
        static let empty = Changes(properties: [:], findObjectStrategy: nil)
        var properties: [String: PropertyModel]
        var findObjectStrategy: FindObjectStrategy?
    }
    
    let entity: NSEntityDescription
    private var _properties: [String: PropertyModel]
    private var _findObjectStrategy: FindObjectStrategy?
    private(set) var storage: JsonDecoderStorage
    
    init(entity: NSEntityDescription, properties: [String: PropertyModel] = [:], findObjectStrategy: FindObjectStrategy? = nil, storage: JsonDecoderStorage) {
        self.entity = entity
        _properties = properties
        _findObjectStrategy = findObjectStrategy
        self.storage = storage
    }
    
    var properties: [String: PropertyModel] {
        var properties = entity.sharedJsonDecoder.entityModel._properties
        for (key, changes) in storage[entity].entityModel._properties {
            properties[key] = properties[key]?.updated(with: changes) ?? changes
        }
        for (key, changes) in _properties {
            properties[key] = properties[key]?.updated(with: changes) ?? changes
        }
        return properties
    }
    
    var findObjectStrategy: FindObjectStrategy {
        set { _findObjectStrategy = newValue }
        get {
            _findObjectStrategy
            ?? storage[entity].entityModel._findObjectStrategy
            ?? entity.sharedJsonDecoder.entityModel._findObjectStrategy
            ?? .none
        }
    }
    
    subscript(key: String) -> PropertyModel? {
        get {
            var keys = key.components(separatedBy: ".")
            let key = keys.removeLast()
            if keys.isEmpty { return properties[key] }
            let path = keys.joined(separator: ".")
            return self[path]?.property?.entityDecoder(with: storage)?.entityModel[key]
        }
        set {
            var keys = key.components(separatedBy: ".")
            let key = keys.removeLast()
            if keys.isEmpty { return _properties[key] = newValue }
            let path = keys.joined(separator: ".")
            guard var entityDecoder = self[path]?.property?.entityDecoder(with: storage) else { return }
            entityDecoder.entityModel[key] = newValue
            self[path]?.property?.setEntityDecoder(entityDecoder)
        }
    }
    
    mutating func updateStorage(_ updater: (inout JsonDecoderStorage) -> Void) {
        updater(&storage)
        _properties = _properties.mapValues {
            var property = $0
            property.updateStorage(updater)
            return property
        }
    }
    
}

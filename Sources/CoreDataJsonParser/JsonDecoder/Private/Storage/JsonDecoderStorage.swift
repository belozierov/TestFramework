//
//  JsonDecoderStorage.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/9/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

public struct JsonDecoderStorage {
    
    private var storage = _JsonDecoderStorage.empty
    private var version: Int { storage.version }
    
    subscript(entity: NSEntityDescription) -> EntityJsonDecoder {
        get { decoder(for: entity) }
        set { setEntityDecoder(newValue, for: entity)}
    }
    
    private func decoder(for entity: NSEntityDescription) -> EntityJsonDecoder {
        if let decoder = storage.decoders[entity] { return decoder }
        let model = EntityModel(entity: entity, storage: self)
        let decoder = EntityJsonDecoder(model: model)
        storage.decoders[entity] = decoder
        return decoder
    }
    
    private mutating func setEntityDecoder(_ decoder: EntityJsonDecoder, for entity: NSEntityDescription) {
        var storages = [Int: JsonDecoderStorage](), newVersions = Set<Int>()
        _setEntityDecoder(decoder, for: entity, storages: &storages, newVersions: &newVersions)
    }
    
    private mutating func _setEntityDecoder(_ decoder: EntityJsonDecoder, for entity: NSEntityDescription, storages: inout [Int: JsonDecoderStorage], newVersions: inout Set<Int>) {
        let oldVersion = version
        var decoders = storage.decoders
        decoders[entity] = decoder
        storage = _JsonDecoderStorage(decoders: decoders)
        storages[oldVersion] = JsonDecoderStorage(storage: storage)
        newVersions.insert(storage.version)
        updateDecoders {
            $0.entityModel.updateStorage { storage in
                if newVersions.contains(storage.version) { return }
                if let exist = storages[storage.version] { return storage = exist }
                storage._setEntityDecoder(decoder, for: entity, storages: &storages, newVersions: &newVersions)
            }
        }
    }
    
    private func updateDecoders(updater: (inout EntityJsonDecoder) -> Void) {
        storage.decoders = storage.decoders.mapValues {
            var decoder = $0
            updater(&decoder)
            return decoder
        }
    }
    
    public subscript<T: NSManagedObject>(type: T.Type) -> ManagedObjectJsonDecoder<T> {
        get { ManagedObjectJsonDecoder(entityDecoder: self[T.entity()]) }
        set { self[T.entity()] = newValue.entityDecoder }
    }
    
    public subscript<O: NSManagedObject, T>(keyPath: KeyPath<O, T>) -> AttributeJsonDecoder<T> {
        get { self[O.self][keyPath] }
        set { self[O.self][keyPath] = newValue }
    }
    
    public subscript<O: NSManagedObject, P: RelationJsonDecodable, R: NSManagedObject>(keyPath: KeyPath<O, P>, type type: R.Type) -> RelationJsonDecoder<R> {
        get { self[O.self][keyPath, type: type] }
        set { self[O.self][keyPath, type: type] = newValue }
    }
    
    public subscript<O: NSManagedObject, R: NSManagedObject>(keyPath: KeyPath<O, Set<R>>) -> RelationJsonDecoder<R> {
        get { self[O.self][keyPath] }
        set { self[O.self][keyPath] = newValue }
    }
    
    public subscript<O: NSManagedObject, R: NSManagedObject>(keyPath: KeyPath<O, R>) -> RelationJsonDecoder<R> {
        get { self[O.self][keyPath] }
        set { self[O.self][keyPath] = newValue }
    }
    
    public subscript<O: NSManagedObject, R: NSManagedObject>(keyPath: KeyPath<O, R?>) -> RelationJsonDecoder<R> {
        get { self[O.self][keyPath] }
        set { self[O.self][keyPath] = newValue }
    }
    
    public func decode<T: NSManagedObject>(of type: T.Type = T.self, json: Json, context: NSManagedObjectContext?) throws -> T {
        try self[T.self].decodeObject(json: json, context: context)
    }
    
    public func decode<T: NSManagedObject>(of type: [T].Type = [T].self, json: Json, context: NSManagedObjectContext?) throws -> [T] {
        try self[T.self].decodeArray(json: json, context: context)
    }
    
}



//
//  ManagedObjectJsonDecoder.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/6/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

public struct ManagedObjectJsonDecoder<Object: NSManagedObject> {
    
    private(set) var entityDecoder: EntityJsonDecoder
    
    init(entityDecoder: EntityJsonDecoder) {
        self.entityDecoder = entityDecoder
    }
    
    public init() {
        let entityModel = EntityModel(entity: Object.entity(), storage: .init())
        entityDecoder = EntityJsonDecoder(model: entityModel)
    }
    
    private func propertyModel<T>(for keyPath: KeyPath<Object, T>) -> PropertyModel {
        let key = self.key(for: keyPath)
        return entityDecoder.entityModel[key] ?? PropertyModel(property: .disable, jsonPath: .key(path: key))
    }
    
    private func key<T>(for keyPath: KeyPath<Object, T>) -> String {
        NSExpression(forKeyPath: keyPath).keyPath
    }
    
    // MARK: - AttributeJsonDecoder
    
    public subscript<T>(keyPath: KeyPath<Object, T>) -> AttributeJsonDecoder<T> {
        get { getDecoder(for: keyPath) }
        set { setDecoder(newValue, for: keyPath) }
    }
    
    private func getDecoder<V, T>(for keyPath: KeyPath<Object, T>) -> AttributeJsonDecoder<V> {
        AttributeJsonDecoder(propertyModel: propertyModel(for: keyPath))
    }
    
    private mutating func setDecoder<V, T>(_ decoder: AttributeJsonDecoder<V>, for keyPath: KeyPath<Object, T>) {
        let key = self.key(for: keyPath)
        var attribute: PropertyModel.Attribute?
        switch decoder.decodeStrategy {
        case .shared:
            attribute = Object.entity().attributesByName[key]?.propertyModelAttribute
        case .custom(let transform):
            attribute = .decoder(transform)
        case .valueTransformer(let name):
            attribute = .valueTransformer(name)
        case .disable:
            entityDecoder.entityModel[key] = PropertyModel(property: .disable, jsonPath: decoder.jsonPath)
            return
        }
        entityDecoder.entityModel[key] = attribute.map {
            PropertyModel(property: .attribute($0), jsonPath: decoder.jsonPath)
        }
    }
    
    // MARK: - RelationJsonDecoder
    
    public subscript<P: RelationJsonDecodable, R: NSManagedObject>(keyPath: KeyPath<Object, P>, type type: R.Type) -> RelationJsonDecoder<R> {
        get { getDecoder(for: keyPath) }
        set { setDecoder(newValue, for: keyPath) }
    }
    
//    subscript<P: RelationJsonDecodable, R: NSManagedObject>(keyPath: KeyPath<Object, P>) -> RelationJsonDecoder<R> {
//        get { return self[keyPath, type: R.self] }
//        set { self[keyPath, type: R.self] = newValue }
//    }
    
    public subscript<R: NSManagedObject>(keyPath: KeyPath<Object, Set<R>>) -> RelationJsonDecoder<R> {
        get { getDecoder(for: keyPath) }
        set { setDecoder(newValue, for: keyPath) }
    }
    
    public subscript<R: NSManagedObject>(keyPath: KeyPath<Object, R>) -> RelationJsonDecoder<R> {
        get { getDecoder(for: keyPath) }
        set { setDecoder(newValue, for: keyPath) }
    }
    
    public subscript<R: NSManagedObject>(keyPath: KeyPath<Object, R?>) -> RelationJsonDecoder<R> {
        get { getDecoder(for: keyPath) }
        set { setDecoder(newValue, for: keyPath) }
    }
    
    private func getDecoder<R, T>(for keyPath: KeyPath<Object, T>) -> RelationJsonDecoder<R> {
        RelationJsonDecoder(propertyModel: propertyModel(for: keyPath))
    }
    
    private mutating func setDecoder<R, T>(_ decoder: RelationJsonDecoder<R>, for keyPath: KeyPath<Object, T>) {
        let key = self.key(for: keyPath)
        var relation: PropertyModel.Relation?
        switch decoder.decodeStrategy {
        case .shared:
            relation = Object.entity().relationshipsByName[key]?.sharedPropertyModelRelation
        case .custom(let entityDecoder):
            guard let model = Object.entity().relationshipsByName[key]?.relationModel else { break }
            relation = .init(entityDecoder: .decoder(entityDecoder.entityDecoder),
                                              relationModel: model)
        case .disable:
            entityDecoder.entityModel[key] = PropertyModel(property: .disable, jsonPath: decoder.jsonPath)
            return
        }
        entityDecoder.entityModel[key] = relation.map {
            PropertyModel(property: .relation($0), jsonPath: decoder.jsonPath)
        }
    }
    
    // MARK: - Decode
    
    @discardableResult
    public func decodeObject(json: Json, context: NSManagedObjectContext?) throws -> Object {
        guard let object = try entityDecoder.parse(json: json, context: context) as? Object
            else { fatalError() }
        return object
    }
    
    @discardableResult
    public func decodeArray(json: Json, context: NSManagedObjectContext?) throws -> [Object] {
        guard let array = json.array else { fatalError() }
        let objects = try array.map { try entityDecoder.parse(json: $0, context: context) }
        if let objects = objects as? [Object] { return objects }
        fatalError()
    }

}

extension ParsableManagedObject where Self: NSManagedObject {
    
    public static var sharedJsonDecoder: ManagedObjectJsonDecoder<Self> {
        get { .init(entityDecoder: entity().sharedJsonDecoder) }
        set { entity().sharedJsonDecoder = newValue.entityDecoder }
    }
    
}

extension Json {
    
    @discardableResult
    public func decode<T: NSManagedObject>(type: T.Type = T.self, context: NSManagedObjectContext?, decoder: ManagedObjectJsonDecoder<T> = .init()) throws -> T {
        try decoder.decodeObject(json: self, context: context)
    }
    
    @discardableResult
    public func decode<T: NSManagedObject>(type: [T].Type = [T].self, context: NSManagedObjectContext?, decoder: ManagedObjectJsonDecoder<T> = .init()) throws -> [T] {
        try decoder.decodeArray(json: self, context: context)
    }
    
}

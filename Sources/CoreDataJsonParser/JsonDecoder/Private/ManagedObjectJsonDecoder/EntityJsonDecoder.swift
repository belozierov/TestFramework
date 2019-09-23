//
//  EntityJsonDecoder.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/8/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

struct EntityJsonDecoder {
    
    private var entityDecoder: EntityObjectJsonDecoder
    
    init(model: EntityModel) {
        entityDecoder = EntityObjectJsonDecoder(entityModel: model)
    }
    
    var entityModel: EntityModel {
        get { entityDecoder.entityModel }
        set {
            isKnownUniquelyReferenced(&entityDecoder)
                ? (entityDecoder.entityModel = newValue)
                : (entityDecoder = entityDecoder.copy(entityModel: newValue))
        }
    }
    
    @inlinable func parse(json: Json, in object: NSManagedObject) throws {
        try entityDecoder.objectParser.value(json, object)
    }
    
    @inlinable func parse(json: Json, context: NSManagedObjectContext?) throws -> NSManagedObject {
        try entityDecoder.byContextParser.value(json, context)
    }
    
    @inlinable func create(json: Json, context: NSManagedObjectContext?) throws -> NSManagedObject {
        try entityDecoder.byContextCreator.value(json, context)
    }
    
    @inlinable func parse(json: Json, context: NSManagedObjectContext, predicate: NSPredicate) throws -> NSManagedObject {
        try entityDecoder.byPredicateParser.value(json, context, predicate)
    }
    
    @inlinable func findObject(json: Json, context: NSManagedObjectContext) throws -> NSManagedObject? {
        try entityDecoder.byJsonSearcher.value(json, context)
    }
    
    @inlinable func findObject(predicate: NSPredicate, context: NSManagedObjectContext) throws -> NSManagedObject? {
        try entityDecoder.byPredicateSearcher.value(predicate, context)
    }
    
    @inlinable func predicate(json: Json) throws -> NSPredicate? {
        try predicateDecoder?(json)
    }
    
    @inlinable var predicateDecoder: EntityObjectJsonDecoder.PredicateDecoder? {
        entityDecoder.predicateDecoder.value
    }
    
}

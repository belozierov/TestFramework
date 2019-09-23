//
//  RelationModel+Decoder.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/8/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

extension RelationModel {
    
    typealias PropertyDecoder = PropertyModel.Decoder<Any?>
    
    func jsonDecoder(decoder: EntityJsonDecoder) -> PropertyDecoder {
        switch relationType {
        case .toOne: return toOneJsonDecoder(decoder: decoder)
        case .toMany(let isOrdered): return toManyJsonDecoder(isOrdered: isOrdered, decoder: decoder)
        }
    }
    
    // MARK: - To One Relation
    
    private func toOneJsonDecoder(decoder: EntityJsonDecoder) -> PropertyDecoder {
        let nilParser: () throws -> Any? = isOptional
            ? { nil }
            : { throw ParseError.nullResultInNotOptionalProperty }
        let parser = deleteRule == .cascade
            ? toOneCascadeRuleParser(decoder: decoder)
            : toOneNotCascadeRuleParser(decoder: decoder)
        return .oldValue { json, oldValue, context in
            if case .null = json { return try nilParser() }
            return try (oldValue as? NSManagedObject).map { try parser(json, $0) }
                ?? decoder.parse(json: json, context: context)
        }
    }
    
    private func toOneCascadeRuleParser(decoder: EntityJsonDecoder) -> (Json, NSManagedObject) throws -> NSManagedObject {
        guard let predicateDecoder = decoder.predicateDecoder else {
            return { json, oldObject in
                try decoder.parse(json: json, in: oldObject)
                return oldObject
            }
        }
        return { json, oldObject in
            let predicate = try predicateDecoder(json)
            if predicate.evaluate(with: oldObject) {
                try decoder.parse(json: json, in: oldObject)
                return oldObject
            } else if let context = oldObject.managedObjectContext {
                let object = try decoder.parse(json: json, context: context, predicate: predicate)
                context.delete(oldObject)
                return object
            }
            return try decoder.create(json: json, context: nil)
        }
    }
    
    private func toOneNotCascadeRuleParser(decoder: EntityJsonDecoder) -> (Json, NSManagedObject) throws -> NSManagedObject {
        guard let predicateDecoder = decoder.predicateDecoder else {
            return { json, oldObject in try decoder.parse(json: json, context: oldObject.managedObjectContext) }
        }
        return { json, oldObject in
            let predicate = try predicateDecoder(json)
            if predicate.evaluate(with: oldObject) {
                try decoder.parse(json: json, in: oldObject)
                return oldObject
            } else if let context = oldObject.managedObjectContext {
                return try decoder.parse(json: json, context: context, predicate: predicate)
            }
            return try decoder.create(json: json, context: nil)
        }
    }
    
    // MARK: - To Many Relation
    
    private func toManyJsonDecoder(isOrdered: Bool, decoder: EntityJsonDecoder) -> PropertyDecoder {
        let setIniter = isOrdered ? { NSOrderedSet(array: $0) } : { NSSet(array: $0) }
        guard deleteRule == .cascade else {
            return .context { json, context in
                setIniter(try decoder.parseToMany(json: json, context: context))
            }
        }
        let objectsGetter = relationObjectsGetter(isOrdered: isOrdered)
        return .oldValue { json, oldValue, context in
            let objects = try decoder.parseToMany(json: json, context: context)
            if let context = context {
                oldValue.flatMap(objectsGetter).map(Set.init)?.subtracting(objects).forEach(context.delete)
            }
            return setIniter(objects)
        }
    }
    
    private func relationObjectsGetter(isOrdered: Bool) -> (Any?) -> [NSManagedObject]? {
        isOrdered
            ? { ($0 as? NSOrderedSet)?.array as? [NSManagedObject] }
            : { ($0 as? NSSet)?.allObjects as? [NSManagedObject] }
    }
    
}

extension EntityJsonDecoder {
    
    fileprivate func parseToMany(json: Json, context: NSManagedObjectContext?) throws -> [NSManagedObject] {
        guard let array = json.array else { throw RelationModel.ParseError.jsonMustBeArrayForToManyRelation }
        return try array.map { json in try parse(json: json, context: context) }
    }
    
}

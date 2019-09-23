//
//  EntityObjectJsonDecoder.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/8/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

class EntityObjectJsonDecoder {
    
    var entityModel: EntityModel {
        didSet { resetCache() }
    }
    
    init(entityModel: EntityModel) {
        self.entityModel = entityModel
    }
    
    func copy(entityModel: EntityModel) -> EntityObjectJsonDecoder {
        EntityObjectJsonDecoder(entityModel: entityModel)
    }
    
    private func resetCache() {
        objectParser.reset()
        byContextParser.reset()
        byContextCreator.reset()
        byPredicateParser.reset()
        byJsonSearcher.reset()
        byPredicateSearcher.reset()
        predicateDecoder.reset()
    }
    
    // MARK: - ObjectParser
    
    lazy var objectParser = ClosureCacher<(Json, NSManagedObject) throws -> Void> {
        [unowned self] in
        var parsers = [(Json, NSManagedObject) throws -> Void]()
        for (key, property) in self.entityModel.properties {
            switch property.decoder(with: self.entityModel.storage) {
            case .json(let decoder):
                parsers.append { json, object in
                    try decoder(json).map { object.setValue($0, forKey: key) }
                }
            case .context(let decoder):
                parsers.append { json, object in
                    try decoder(json, object.managedObjectContext)
                        .map { object.setValue($0, forKey: key) }
                }
            case .oldValue(let decoder):
                parsers.append { json, object in
                    try decoder(json, object.value(forKey: key), object .managedObjectContext)
                        .map { object.setValue($0, forKey: key) }
                }
            case nil: break
            }
        }
        return { json, object in
            try parsers.forEach { try $0(json, object) }
            try object.validateForUpdate()
        }
    }
    
    // MARK: - ByContextParser
    
    typealias ByContextParser = (Json, NSManagedObjectContext?) throws -> NSManagedObject
    
    lazy var byContextParser = ClosureCacher<ByContextParser> { [unowned self] in
        let creator = self.byContextCreator.value
        let finder = self.byJsonSearcher.value
        let parser = self.objectParser.value
        return { json, context in
            guard let moc = context else { return try creator(json, nil) }
            return try finder(json, moc).map { object in
                try parser(json, object)
                return object
                } ?? creator(json, context)
        }
    }
    
    // MARK: - ByPredicateParser
    
    typealias ObjectCreator = (Json, NSManagedObjectContext?) throws -> NSManagedObject
    
    lazy var byContextCreator = ClosureCacher<ObjectCreator> {
        [unowned self] in
        let parser = self.objectParser.value
        let entity = self.entityModel.entity
        return { json, context in
            let object = NSManagedObject(entity: entity, insertInto: context)
            try parser(json, object)
            return object
        }
    }
    
    // MARK: - ByPredicateParser
    
    typealias ByPredicateParser = (Json, NSManagedObjectContext, NSPredicate) throws -> NSManagedObject
    
    lazy var byPredicateParser = ClosureCacher<ByPredicateParser> { [unowned self] in
        let finder = self.byPredicateSearcher.value
        let parser = self.objectParser.value
        let creator = self.byContextCreator.value
        return { json, context, predicate in
            try finder(predicate, context).map { object in
                try parser(json, object)
                return object
            } ?? creator(json, context)
        }
    }
    
    // MARK: - ByJsonSearcher
    
    typealias ByJsonSearcher = (Json, NSManagedObjectContext) throws -> NSManagedObject?
    
    lazy var byJsonSearcher = ClosureCacher<ByJsonSearcher> { [unowned self] in
        guard let decoder = self.predicateDecoder.value else { return { _, _ in nil } }
        let finder = self.byPredicateSearcher.value
        return { json, context in try finder(try decoder(json), context) }
    }
    
    // MARK: - ByPredicateSearcher
    
    typealias ByPredicateSearcher = (NSPredicate, NSManagedObjectContext) throws -> NSManagedObject?
    
    lazy var byPredicateSearcher = ClosureCacher<ByPredicateSearcher> { [unowned self] in
        guard let name = self.entityModel.entity.name else {
            return { _, _ in throw ParseError.noEntityName }
        }
        let request = NSFetchRequest<NSManagedObject>(entityName: name)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return { predicate, context in
            request.predicate = predicate
            return try context.fetch(request).first
        }
    }
    
    // MARK: - PredicateDecoder
    
    typealias PredicateDecoder = (Json) throws -> NSPredicate
    
    lazy var predicateDecoder = ClosureCacher<PredicateDecoder?> { [unowned self] in
        switch self.entityModel.findObjectStrategy {
        case .byConstraints(let constraints) where !constraints.isEmpty:
            return self.byConstrainsPredicateDecoder(constraints: constraints)
        case .predicate(let decoder):
            return decoder
        default:
            return nil
        }
    }
    
    private func byConstrainsPredicateDecoder(constraints: [[String]]) -> PredicateDecoder? {
        let keys = Set(constraints.flatMap { $0 })
        let properties = self.entityModel.properties.filter { keys.contains($0.key) }
        let decoders = properties.mapValues { (property) -> (Json) throws -> Any?? in
            if case .json(let decoder) = property.decoder(with: self.entityModel.storage) { return decoder }
            fatalError()
        }
        if keys.count != properties.count { fatalError() }
        return { json in
            var orPredicates = [NSPredicate]()
            for constraint in constraints {
                var andPredicates = [NSPredicate]()
                for key in constraint {
                    guard let valueParser = decoders[key], let value = try valueParser(json)
                        else { fatalError() }
                    let right = NSExpression(forConstantValue: value)
                    let predicate = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: key),
                                                          rightExpression: right,
                                                          modifier: .direct, type: .equalTo)
                    andPredicates.append(predicate)
                }
                guard let predicate = andPredicates.compounded(by: .and) else { fatalError() }
                orPredicates.append(predicate)
            }
            return orPredicates.compounded(by: .or)!
        }
    }
    
}

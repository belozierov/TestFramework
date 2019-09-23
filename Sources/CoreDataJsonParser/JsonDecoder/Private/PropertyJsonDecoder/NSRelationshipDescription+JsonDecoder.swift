//
//  NSRelationshipDescription+JsonDecoder.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/4/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

extension NSRelationshipDescription {
    
    var sharedPropertyModel: PropertyModel? {
        guard let relation = sharedPropertyModelRelation else { return nil }
        return PropertyModel(property: .relation(relation), jsonPath: jsonPath)
    }
    
    var sharedPropertyModelRelation: PropertyModel.Relation? {
        guard let model = relationModel else { return nil }
        return PropertyModel.Relation(entityDecoder: .storage, relationModel: model)
    }
    
    var relationModel: RelationModel? {
        guard let deleteRule = self.deleteRule.rule, let entity = destinationEntity else { return nil }
        return RelationModel(entity: entity, relationType: relationType, deleteRule: deleteRule, isOptional: isOptional)
    }
    
    private var relationType: RelationModel.RelationType {
        isToMany ? .toMany(isOrdered: isOrdered) : .toOne
    }
    
}

extension NSDeleteRule {
    
    fileprivate var rule: RelationModel.DeleteRule? {
        switch self {
        case .cascadeDeleteRule: return .cascade
        case .denyDeleteRule: return .deny
        case .noActionDeleteRule: return .noAction
        case .nullifyDeleteRule: return .nullify
        @unknown default: return nil
        }
    }
    
}

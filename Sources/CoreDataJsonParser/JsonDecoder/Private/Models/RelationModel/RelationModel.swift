//
//  RelationModel.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/7/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

struct RelationModel {
    
    enum RelationType {
        case toOne, toMany(isOrdered: Bool)
    }
    
    enum DeleteRule {
        case noAction, nullify, cascade, deny
    }
    
    let entity: NSEntityDescription
    let relationType: RelationType
    let deleteRule: DeleteRule
    let isOptional: Bool
    
}

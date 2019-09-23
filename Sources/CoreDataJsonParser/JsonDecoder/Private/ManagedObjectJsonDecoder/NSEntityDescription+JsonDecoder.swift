//
//  NSEntityDescription+JsonDecoder.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/7/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

extension NSEntityDescription {
    
    var sharedJsonDecoder: EntityJsonDecoder {
        set { _userInfo[.jsonDecoder] = newValue }
        get {
            if let entityDecoder = userInfo?[.jsonDecoder] as? EntityJsonDecoder {
                return entityDecoder
            }
            let model = entityModel(with: JsonDecoderStorage())
            let entityDecoder = EntityJsonDecoder(model: model)
            _userInfo[.jsonDecoder] = entityDecoder
            return entityDecoder
        }
    }
    
    private var _userInfo: [AnyHashable: Any] {
        get { userInfo ?? [:] }
        set { userInfo = newValue }
    }
    
    func entityModel(with storage: JsonDecoderStorage) -> EntityModel {
        var properties = [String: PropertyModel]()
        for (name, attribute) in attributesByName {
            properties[name] = attribute.propertyModel
        }
        for (name, relation) in relationshipsByName {
            properties[name] = relation.sharedPropertyModel
        }
        return EntityModel(entity: self, properties: properties,
                           findObjectStrategy: findObjectStrategy, storage: storage)
    }
    
    var findObjectStrategy: EntityModel.FindObjectStrategy {
        guard let constraints = uniquenessConstraints as? [[String]],
            !constraints.isEmpty else { return .none }
        return .byConstraints(constraints)
    }
    
}

extension AnyHashable {
    
    fileprivate static let jsonDecoder = "jsonDecoder"
    
}

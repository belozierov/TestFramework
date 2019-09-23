//
//  RelationModel+ParseError.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/19/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

extension RelationModel {
    
    enum ParseError: Error {
        case nullResultInNotOptionalProperty
        case jsonMustBeArrayForToManyRelation
    }
    
}

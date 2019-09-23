//
//  ValueTransformer.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/7/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

extension NSValueTransformerName {
    
    func decode(json: Json) throws -> Any? {
        guard let transformer = ValueTransformer(forName: self) else { fatalError() }
        return transformer.transformedValue(json.any)
    }
    
}

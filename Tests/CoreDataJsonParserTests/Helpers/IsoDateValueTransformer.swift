//
//  IsoDateValueTransformer.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

class IsoDateValueTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        (value as? String).flatMap(ISO8601DateFormatter.standart.date)
    }
    
}

extension ValueTransformer {
    
    static func registerIsoDateTransformer() {
        let name = NSValueTransformerName(rawValue: "IsoDate")
        ValueTransformer.setValueTransformer(IsoDateValueTransformer(), forName: name)
    }
    
}

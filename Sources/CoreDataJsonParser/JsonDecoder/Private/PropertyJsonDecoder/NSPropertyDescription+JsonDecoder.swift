//
//  NSPropertyDescription+JsonDecoder.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/7/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

extension NSPropertyDescription {
    
    var jsonPath: JsonDecoderPath {
        .key(path: userInfo?["jsonPath"] as? String ?? name)
    }
    
}

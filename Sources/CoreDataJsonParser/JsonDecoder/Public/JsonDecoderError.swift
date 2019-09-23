//
//  JsonDecoderError.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/7/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

enum JsonDecoderError: Error {
    case attribute(entity: String?, attribute: String, description: String)
    
    
    
}

//
//  ISO8601DateFormatter.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation
import CoreDataJsonParser

extension ISO8601DateFormatter {
    
    static let standart: ISO8601DateFormatter = {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return isoFormatter
    }()
    
}

extension AttributeJsonDecoder.DecodeStrategy where Value == Date? {
    
    static let isoDate = AttributeJsonDecoder<Date?>.DecodeStrategy
        .custom { $0.transform(ISO8601DateFormatter.standart.date) }
    
}

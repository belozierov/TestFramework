//
//  NSPredicate.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 8/13/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

extension Array where Element: NSPredicate {
    
    func compounded(by type: NSCompoundPredicate.LogicalType) -> NSPredicate? {
        if count == 0 { return nil }
        if count == 1, [.or, .and].contains(type) { return self[0] }
        return NSCompoundPredicate(type: type, subpredicates: self)
    }
    
}

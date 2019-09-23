//
//  ClosureCacher.swift
//  CoreDataJsonParser
//
//  Created by Alex Belozierov on 9/7/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

class ClosureCacher<T> {
    
    private let creator: () -> T
    private var cache: T?
    
    init(creator: @escaping () -> T) {
        self.creator = creator
    }
    
    @inlinable var value: T {
        if let closure = cache { return closure }
        let closure = creator()
        cache = closure
        return closure
    }
    
    func reset() {
        cache = nil
    }
    
}

//
//  Json+Subscription.swift
//  FutureNet
//
//  Created by Alex Belozierov on 6/25/19.
//  Copyright © 2019 GTM. All rights reserved.
//

import Foundation

extension Json {
    
    public var array: [Json]? {
        guard case .array(let array) = self else { return nil }
        return array.compactMap(Json.init)
    }
    
    public var dictionary: [String: Json]? {
        anyDictionary?.compactMapValues(Json.init)
    }
    
    public var any: Any {
        switch self {
        case .array(let array): return array
        case .dictionary(let dict): return dict
        case .number(let number): return number
        case .string(let string): return string
        case .null: return NSNull()
        }
    }
    
    private var anyDictionary: [String: Any]? {
        guard case .dictionary(let dict) = self else { return nil }
        return dict
    }
    
    public subscript(index: Int) -> Json? {
        guard case .array(let array) = self,
            index < array.count else { return nil }
        return Json(value: array[index])
    }
    
    public subscript<T: JsonConvertable>(index: Int) -> T? {
        self[index].flatMap(T.init)
    }
    
    public subscript(key: String) -> Json? {
        anyDictionary?[key].flatMap(Json.init)
    }
    
    public subscript<T: JsonConvertable>(key: String) -> T? {
        self[key].flatMap(T.init)
    }
    
    public subscript(dynamicMember member: String) -> Json? {
        self[member]
    }
    
    public subscript<T: JsonConvertable>(dynamicMember member: String) -> T? {
        self[member]
    }
    
    public func convert<T: JsonConvertable>(to type: T.Type = T.self) -> T? {
        T(json: self)
    }
    
    public func transform<T: JsonConvertable, N>(_ transform: (T) throws -> N) rethrows -> N? {
        try convert().map(transform)
    }
    
    public func transform<T: JsonConvertable, N>(_ transform: (T) throws -> N?) rethrows -> N? {
        try convert().flatMap(transform)
    }
    
}

extension Optional where Wrapped == Json {
    
    public subscript(key: String) -> Json? {
        self?[key]
    }
    
    public subscript<T: JsonConvertable>(key: String) -> T? {
        self?[key]
    }
    
    public subscript(index: Int) -> Json? {
        self?[index]
    }
    
    public subscript<T: JsonConvertable>(index: Int) -> T? {
        self?[index]
    }
    
}

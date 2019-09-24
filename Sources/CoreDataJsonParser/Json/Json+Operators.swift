//
//  Json_Functions.swift
//  FutureNet
//
//  Created by Alex Belozierov on 6/25/19.
//  Copyright © 2019 GTM. All rights reserved.
//

import Foundation

infix operator <- :AditinalPrecedence
infix operator <~ :AditinalPrecedence

precedencegroup AditinalPrecedence {
    associativity: right
    lowerThan: NilCoalescingPrecedence
}

public func <- <T: JsonConvertable>(left: inout T, right: Json?) {
    left <- right.flatMap(T.init)
}

public func <- <T: JsonConvertable>(left: inout T?, right: Json?) {
    right.flatMap(T.init).map { left = $0 }
}

public func <- <T: JsonConvertable>(left: inout T, right: T?) {
    right.map { left = $0 }
}

public func <- <T: JsonConvertable>(left: inout T?, right: T?) {
    right.map { left = $0 }
}

public func <~ <T: JsonConvertable>(left: inout T, right: Json?) throws {
    try left <~ right.flatMap(T.init)
}

public func <~ <T: JsonConvertable>(left: inout T?, right: Json?) throws {
    guard let value = right.flatMap(T.init) else { throw URLError(.cannotParseResponse) }
    try left <~ value
}

public func <~ <T: JsonConvertable>(left: inout T, right: T?) throws {
    guard let value = right else { throw URLError(.cannotParseResponse) }
    left = value
}

public func <~ <T: JsonConvertable>(left: inout T?, right: T?) throws {
    guard let value = right else { throw URLError(.cannotParseResponse) }
    left = value
}

extension Optional where Wrapped == Json {
    
    public func tryConvert<T: JsonConvertable>() throws -> T {
        return try self?.tryConvert() ?? { throw URLError(.cannotParseResponse) }()
    }
    
    public func tryMap<T>(_ transform: (Json) -> T?) throws -> T {
        return try self?.tryMap(transform) ?? { throw URLError(.cannotParseResponse) }()
    }
    
}

extension Json {
    
    public func tryConvert<T: JsonConvertable>() throws -> T {
        return try convert() ?? { throw URLError(.cannotParseResponse) }()
    }
    
    public func tryMap<T>(_ transform: (Json) -> T?) throws -> T {
        return try transform(self) ?? { throw URLError(.cannotParseResponse) }()
    }
    
}

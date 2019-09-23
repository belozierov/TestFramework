//
//  Json+Values.swift
//  FutureNet
//
//  Created by Alex Belozierov on 6/25/19.
//  Copyright © 2019 GTM. All rights reserved.
//

import Foundation

public protocol JsonConvertable {
    
    init?(json: Json)
    
}

extension Dictionary: JsonConvertable where Key == String {
    
    public init?(json: Json) {
        guard case .dictionary(let raw) = json,
            let dict = raw as? Dictionary else { return nil }
        self = dict
    }
    
}

extension Array: JsonConvertable {
    
    public init?(json: Json) {
        guard case .array(let raw) = json,
            let array = raw as? Array else { return nil }
        self = array
    }
    
}

extension String: JsonConvertable {
    
    public init?(json: Json) {
        switch json {
        case .string(let string):
            self = string
        case .number(let number):
            self = number.stringValue
        default:
            return nil
        }
    }
    
}

extension URL: JsonConvertable {
    
    public init?(json: Json) {
        switch json {
        case .string(let string):
            guard let url = URL(string: string) else { return nil }
            self = url
        default:
            return nil
        }
    }
    
}

extension UUID: JsonConvertable {
    
    public init?(json: Json) {
        switch json {
        case .string(let string):
            guard let uuid = UUID(uuidString: string.uppercased()) else { return nil }
            self = uuid
        default:
            return nil
        }
    }
    
}

extension Date: JsonConvertable {
    
    public init?(json: Json) {
        switch json {
        case .string(let string):
            if let date = ISO8601DateFormatter().date(from: string) {
                self = date
            } else {
                return nil
            }
        case .number(let number):
            self = Date(timeIntervalSince1970: number.doubleValue)
        default:
            return nil
        }
    }
    
}

public protocol JsonNumberConvertible: JsonConvertable {
    
    init?(_: String)
    init?(truncating: NSNumber)
    
}

extension JsonNumberConvertible {
    
    public init?(json: Json) {
        switch json {
        case .string(let string):
            self.init(string)
        case .number(let number):
            self.init(truncating: number)
        default:
            return nil
        }
    }
    
}

extension Bool: JsonNumberConvertible {}
extension Int: JsonNumberConvertible {}
extension Int8: JsonNumberConvertible {}
extension Int16: JsonNumberConvertible {}
extension Int32: JsonNumberConvertible {}
extension Int64: JsonNumberConvertible {}
extension UInt: JsonNumberConvertible {}
extension UInt8: JsonNumberConvertible {}
extension UInt16: JsonNumberConvertible {}
extension UInt32: JsonNumberConvertible {}
extension UInt64: JsonNumberConvertible {}
extension Float: JsonNumberConvertible {}
extension Double: JsonNumberConvertible {}

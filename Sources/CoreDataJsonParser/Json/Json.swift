//
//  Json.swift
//  FutureNet
//
//  Created by Alex Belozierov on 6/25/19.
//  Copyright © 2019 GTM. All rights reserved.
//

import Foundation

@dynamicMemberLookup public enum Json {
    
    case string(String)
    case number(NSNumber)
    case dictionary([String: Any])
    case array([Any])
    case null
    
    public init?(data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            else { return nil }
        self.init(value: json)
    }
    
    public init?(value: Any) {
        switch value {
        case let number as NSNumber:
            self = .number(number)
        case let string as String:
            self = .string(string)
        case let dictionary as [String: Any]:
            self = .dictionary(dictionary)
        case let array as [Any]:
            self = .array(array)
        case is NSNull:
            self = .null
        default:
            return nil
        }
    }
    
}

//extension Json: Equatable {
//    
//    public static func == (lhs: Json, rhs: Json) -> Bool {
//        switch (lhs, rhs) {
//        case (.string(let left), .string(let right)):
//            return left == right
//        case (.number(let left), .number(let right)):
//            return left.isEqual(to: right)
//        case (.null, .null):
//            return true
//        case (.dictionary, .dictionary):
//            return lhs.dictionary == rhs.dictionary
//        case (.array, .array):
//            return lhs.array == rhs.array
//        default:
//            return false
//        }
//    }
//    
//}

//
//  PrimitiveTypeCacheableExtension.swift
//  HDCommons
//
//  Created by Balraj Singh on 05/09/18.
//

import Foundation
import RocketData

extension String: Cacheable {
    public init(jsonString: String) {
        self.init()
        self = jsonString
    }
    
    public func forEach(_ visit: (Model) -> Void) {
        // Do nothing
    }
    
    public func toJsonString() -> String {
        return self
    }
    
    public func map(_ transform: (Model) -> Model?) -> String? {
        return self
    }
    
    public var modelIdentifier: String? { return nil }
}

extension Bool: Cacheable {
    public init(jsonString: String) {
        self.init()
        self = jsonString.boolValue
    }
    
    public func forEach(_ visit: (Model) -> Void) {
        // Do nothing
    }
    
    public func toJsonString() -> String {
        return String(self)
    }
    
    public func map(_ transform: (Model) -> Model?) -> Bool? {
        return self
    }
    
    public var modelIdentifier: String? { return nil }
}

extension Int: Cacheable {
    public init(jsonString: String) {
        self.init()
        self = (Int(jsonString) ?? 0)
    }
    
    public func forEach(_ visit: (Model) -> Void) {
        // Do nothing
    }
    
    public func toJsonString() -> String {
        return String(self)
    }
    
    public func map(_ transform: (Model) -> Model?) -> Int? {
        return self
    }
    
    public var modelIdentifier: String? { return nil }
}

extension Float: Cacheable {
    public init(jsonString: String) {
        self.init()
        self = (Float(jsonString) ?? 0)
    }
    
    public func forEach(_ visit: (Model) -> Void) {
        // Do nothing
    }
    
    public func toJsonString() -> String {
        return String(self)
    }
    
    public func map(_ transform: (Model) -> Model?) -> Float? {
        return self
    }
    
    public var modelIdentifier: String? { return nil }
}



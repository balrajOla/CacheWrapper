//
//  CachedAttributes.swift
//  HDCommons
//
//  Created by Balraj Singh on 05/09/18.
//

import Foundation
import PromiseKit
import RocketData

public class CachedAttributes {
    public static let sharedInstance = CachedAttributes()
    
    public func save<T: Codable & Equatable>(value: CacheableValue<T>?) {
        CaheContext().setData(value)
    }
    
    public func get<T>(_ key: String) -> Promise<CacheableValue<T>> where T: Codable & Equatable {
        return CaheContext().fetchDataFromCache(withCacheKey: key)
    }
    
    public func delete(_ key: String) {
        firstly {.value(CacheableValue<String>(key, nil)) }
            .done {(data: CacheableValue<String>) in CaheContext().removeData(data)}
    }
}

public struct CacheableValue<T>: Cacheable where T: Codable & Equatable {
    var id: String?
    var value: T?
    
    public init(_ id: String,_ value: T?) {
        self.id = id
        self.value = value
    }
    
    public func getValue() -> T? {
        return value
    }
    
    public func isEqual(to model: Model) -> Bool {
        guard let modelValue = model as? CacheableValue,
             let value1 = modelValue.value,
             let value2 = self.value else {
            return false
        }
        
        return (value1 == value2)
    }
    
    public init(jsonString: String) {
        // Decode the json String
        if let dataValue = jsonString.data(using: String.Encoding.utf8) {
            self.value = (try? JSONDecoder().decode([T].self, from: dataValue))?.first
        }
    }
    
    public func forEach(_ visit: (Model) -> Void) {
        // Do nothing
    }
    
    public func toJsonString() -> String {
        // Encode to json string
        guard let valueToEncode = self.value,
             let jsonData = try? JSONEncoder().encode([valueToEncode]),
             let json = String(data: jsonData, encoding: String.Encoding.utf8) else {
            return ""
        }
        
        return json
    }
    
    public func map(_ transform: (Model) -> Model?) -> CacheableValue? {
        return self
    }
    
    public var modelIdentifier: String? { return id }
}

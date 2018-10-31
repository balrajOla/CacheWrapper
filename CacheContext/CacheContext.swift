//
//  NewStorageContextProtocol.swift
//  HDCommons
//
//  Created by Balraj Singh on 03/09/18.
//

import Foundation
import RocketData
import Cache
import PromiseKit

// Persistent Configuration
public struct PersistentCacheConfig {
    /// The name of disk storage, this will be used as folder name within directory
    public let name: String
    /// Expiry date that will be applied by default for every added object
    /// if it's not overridden in the add(key: object: expiry: completion:) method
    public let expiry: CacheExpiryConfig
    /// Maximum size of the disk cache storage (in bytes)
    public let maxSize: UInt
    /// A folder to store the disk cache contents. Defaults to a prefixed directory in Caches if nil
    public let directory: URL?
    
    public init(name: String,
                expiry: CacheExpiryConfig = .never,
                maxSize: UInt = 0,
                directory: URL? = nil) {
        self.name = name
        self.expiry = expiry
        self.maxSize = maxSize
        self.directory = directory
    }
}

/**
 Helper enum to set the expiration date
 */
public enum CacheExpiryConfig {
    /// Object will be expired in the nearest future
    case never
    /// Object will be expired in the specified amount of seconds
    case seconds(TimeInterval)
    /// Object will be expired on the specified date
    case date(Date)
    
    public func getStorageExpiryConfig() -> Expiry {
        switch self {
        case .never:
            return .never
        case .seconds(let interval):
            return .seconds(interval)
        case .date(let date):
            return .date(date)
        }
    }
}

// Stores only single type of configuration
public enum CachingConfig {
    case persistent(PersistentCacheConfig)
    
    // default Init
    public static func defaultInstance() -> CachingConfig {
        return .persistent(PersistentCacheConfig(name: "Halodoc_Doctor"))
    }
}

// Storage Context Delegate
public protocol CacheContextDelegate: DataProviderDelegate {
    func updatedData<T>(_ data: T, context: Any?)
}

extension CacheContextDelegate {
    func dataProviderHasUpdatedData<T>(_ dataProvider: DataProvider<T>, context: Any?) {
        self.updatedData(dataProvider.data, context: context)
    }
}


// Storage Context Protocol
public class CaheContext<T: Cacheable> {
    private let dataProvider: DataProvider<T>
    
    // initialise with config and delegate
    public init() {
        self.dataProvider = DataProvider()
    }
    
    public func setDelegate(_ delegate: CacheContextDelegate) {
        self.dataProvider.delegate = delegate
    }
    
    public var isPaused: Bool {
        get {
            return self.dataProvider.isPaused
        }
        set {
            return self.dataProvider.isPaused = newValue
        }
    }
    
    public var data: T? {
        get {
            return self.dataProvider.data
        }
    }
    
    public func setData(_ data: T?, updateCache: Bool = true, context: Any? = nil) {
        self.dataProvider.setData(data, updateCache: updateCache, context: context)
    }
    
    public func fetchDataFromCache(withCacheKey cacheKey: String?, context: Any? = nil) -> Promise<T> {
        return Promise<T>() { seal in
            self.dataProvider.fetchDataFromCache(withCacheKey: cacheKey, listenToModelIdentifier: true, context: context, completion: {(value, error) in
                guard let result = value else {
                    if let err = error {
                       seal.reject(err)
                    } else {
                        seal.reject(CacheError.notFound)
                    }
                    
                    return
                }
                
                seal.fulfill(result)
            })
        }
    }
    
    public func removeData(_ data: T, updateCache: Bool = true, context: Any? = nil) {
        self.dataProvider.dataModelManager.deleteModel(data, updateCache: updateCache, context: context)
    }
}

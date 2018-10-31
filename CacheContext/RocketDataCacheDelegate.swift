//
//  RocketDataCacheDelegate.swift
//  HDCommons
//
//  Created by Balraj Singh on 03/09/18.
//

import Foundation
import RocketData
import Cache


class RocketDataCacheDelegate: CacheDelegate {
    
    /**
     This is the underlying cache implementation. We're going to use a Cache Library because it's thread safe (so we can avoid using GCD here).
     You should feel free to use any cache you'd like.
     */
    
    private var cache: DiskStorage<String>?
    
    init(config: CachingConfig = CachingConfig.defaultInstance()) {
        switch config {
        case .persistent(let persistentConfig):
            self.setUpStorage(withPersistentConfig: persistentConfig)
        }
    }
    private func setUpStorage(withPersistentConfig config: PersistentCacheConfig) {
        let diskStorageConfig = DiskConfig(name: config.name,
                                           expiry: config.expiry.getStorageExpiryConfig(),
                                           maxSize: config.maxSize,
                                           directory: config.directory)
        
        self.cache = try? DiskStorage<String>(config: diskStorageConfig, transformer: TransformerFactory.forCodable(ofType: String.self))
    }
    
    func modelForKey<T : SimpleModel>(_ cacheKey: String?, context: Any?, completion: @escaping (T?, NSError?) -> ()) {
        guard let modelType = T.self as? Cacheable.Type else {
            completion(nil, (CacheError.notConfirmingCacheable as NSError))
            return
        }
        
        guard let keyStr = cacheKey,
            let storedValue = try? self.cache?.object(forKey: keyStr),
            let value = storedValue else {
            completion(nil, (CacheError.notFound as NSError))
            return
        }
        
        completion((modelType.init(jsonString: value) as? T), nil)
    }
    
    func setModel(_ model: SimpleModel, forKey cacheKey: String, context: Any?) {
        if let model = model as? Cacheable {
            try? cache?.setObject(model.toJsonString(), forKey: cacheKey, expiry: nil)
        } else {
            assertionFailure("In our app, we only want to use RocketData with SampleAppModels")
        }
    }
    
    func collectionForKey<T : SimpleModel>(_ cacheKey: String?, context: Any?, completion: @escaping ([T]?, NSError?) -> ()) {
        guard let cacheKey = cacheKey,
            let collectionCacheValueJson = try? cache?.object(forKey: cacheKey),
            let collectionCacheValueData = collectionCacheValueJson?.data(using: .utf8),
            let collectionCacheValue = try? JSONDecoder().decode([String].self, from: collectionCacheValueData),
            let modelType = T.self as? Cacheable.Type else {
                completion(nil, (CacheError.notConfirmingCacheable as NSError))
                return
        }

        
        
        let collection: [T] = collectionCacheValue.compactMap {
            guard let data = try? cache?.object(forKey: $0),
                  let value = data,
                  let finalValue = (modelType.init(jsonString: value) as? T) else {
                completion(nil, (CacheError.notConfirmingCacheable as NSError))
                return nil
            }
            
            return finalValue
        }
        
        completion(collection, nil)
    }
    
    func setCollection(_ collection: [SimpleModel], forKey cacheKey: String, context: Any?) {
        // In this method, we're going to store an array of strings for the collection and cache all the models individually
        // This means updating one of the models will automatically update the collection
        
        collection.forEach { model in
            if let cacheKey = model.modelIdentifier,
                let model = model as? Cacheable {
                try? cache?.setObject(model.toJsonString(), forKey: cacheKey, expiry: nil)
            } else {
                assertionFailure("This should never happen because all of our collection models have ids")
            }
        }

        let collectionCacheValue = collection.compactMap {
            return $0.modelIdentifier
        }
        
        // convert that data to JSON String
        guard let jsonData = try? JSONEncoder().encode(collectionCacheValue),
            let jsonString = String(data: jsonData, encoding: .utf8) else {
                assertionFailure("JSON Encoding is causing issues for [Strings]")
                return
        }

        try? cache?.setObject(jsonString, forKey: cacheKey, expiry: nil)
    }
    
    func deleteModel(_ model: SimpleModel, forKey cacheKey: String?, context: Any?) {
        guard let cacheKey = cacheKey else {
            return
        }
        try? cache?.removeObject(forKey: cacheKey)
    }
}

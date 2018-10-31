//
//  RocketDataUtils.swift
//  HDCommons
//
//  Created by Balraj Singh on 03/09/18.
//

import Foundation
import RocketData
import Cache

/**
 This file contains some useful setup you could do.
 */

// It will be responsible to initialise Caching layer with config throughout the app
public struct CacheDataModelManager {
    fileprivate static var sharedInstance: DataModelManager?
    private init(){ }
    public static func initialise(withConfig config: CachingConfig) {
        sharedInstance = DataModelManager(cacheDelegate: RocketDataCacheDelegate(config: config))
    }
}

extension DataModelManager {
    /**
     Singleton accessor for DataModelManager
     */
    static let sharedInstance = DataModelManager(cacheDelegate: RocketDataCacheDelegate())
}

extension DataProvider {
    convenience init() {
        guard let dataModelManager = CacheDataModelManager.sharedInstance else {
            fatalError("Initialise CacheDataModel Manager First")
        }
        
        self.init(dataModelManager: dataModelManager)
    }
}

public enum CacheError: Error {
    /// Object can not be found
    case notFound
    /// Object is found, but casting to requested type failed
    case typeNotMatch
    /// The file attributes are malformed
    case malformedFileAttributes
    /// Can't perform Decode
    case decodingFailed
    /// Can't perform Encode
    case encodingFailed
    /// The storage has been deallocated
    case deallocated
    /// Fail to perform transformation to or from Data
    case transformerFail
    // Object not confirming to Cacheable protocol
    case notConfirmingCacheable
    
    public static func map(error: Cache.StorageError) -> CacheError {
        switch error {
        /// Object can not be found
        case .notFound:
            return .notFound
            
        /// Object is found, but casting to requested type failed
        case .typeNotMatch:
            return .typeNotMatch
            
        /// The file attributes are malformed
        case .malformedFileAttributes:
            return .malformedFileAttributes
            
        /// Can't perform Decode
        case .decodingFailed:
            return .decodingFailed
            
        /// Can't perform Encode
        case .encodingFailed:
            return .encodingFailed
            
        /// The storage has been deallocated
        case .deallocated:
            return .deallocated
            
        /// Fail to perform transformation to or from Data
        case .transformerFail:
            return .transformerFail
        }
    }
}

public protocol Cacheable: Model, Codable {
    init(jsonString: String)
    func toJsonString() -> String
}



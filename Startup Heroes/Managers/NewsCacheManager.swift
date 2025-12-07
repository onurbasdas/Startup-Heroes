//
//  NewsCacheManager.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation

protocol NewsCacheManagerProtocol {
    func saveNews(_ news: [News])
    func getCachedNews() -> [News]?
    func isCacheValid() -> Bool
    func clearCache()
}

class NewsCacheManager: NewsCacheManagerProtocol {
    
    private let userDefaults: UserDefaults
    private let cacheKey = "CachedNews"
    private let cacheTimestampKey = "CachedNewsTimestamp"
    private let cacheTTL: TimeInterval = 3600 // 1 saat
    private let maxCacheSize = 50 // Maksimum 50 haber cache'lenir
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveNews(_ news: [News]) {
        let newsToCache = Array(news.prefix(maxCacheSize))
        
        guard let encoded = try? JSONEncoder().encode(newsToCache) else {
            return
        }
        
        userDefaults.set(encoded, forKey: cacheKey)
        userDefaults.set(Date().timeIntervalSince1970, forKey: cacheTimestampKey)
    }
    
    func getCachedNews() -> [News]? {
        guard let data = userDefaults.data(forKey: cacheKey) else {
            return nil
        }
        
        guard let news = try? JSONDecoder().decode([News].self, from: data) else {
            return nil
        }
        
        return news
    }
    
    func isCacheValid() -> Bool {
        guard let timestamp = userDefaults.object(forKey: cacheTimestampKey) as? TimeInterval else {
            return false
        }
        
        let cacheAge = Date().timeIntervalSince1970 - timestamp
        return cacheAge < cacheTTL
    }
    
    func clearCache() {
        userDefaults.removeObject(forKey: cacheKey)
        userDefaults.removeObject(forKey: cacheTimestampKey)
    }
}


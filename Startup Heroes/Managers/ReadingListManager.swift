//
//  ReadingListManager.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation
import Combine

protocol ReadingListManagerProtocol {
    func addToReadingList(_ news: News)
    func removeFromReadingList(_ news: News)
    func isInReadingList(_ news: News) -> Bool
    func getAllReadingListItems() -> [News]
}

class ReadingListManager: ReadingListManagerProtocol {
    
    private let userDefaults: UserDefaults
    private let readingListKey = Constants.readingListKey
    private var cachedReadingList: [News]?
    private var cacheTimestamp: Date?
    private let cacheValidityDuration: TimeInterval = 1.0 // 1 saniye cache
    
    // Combine publisher for reading list changes
    let readingListDidChange = PassthroughSubject<Void, Never>()
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func addToReadingList(_ news: News) {
        var readingList = getAllReadingListItems()
        
        if !isInReadingList(news) {
            readingList.insert(news, at: 0)
            saveReadingList(readingList)
            // Invalidate cache to ensure fresh data on next read
            cachedReadingList = nil
            cacheTimestamp = nil
            // Notify subscribers about the change
            readingListDidChange.send()
        }
    }
    
    func removeFromReadingList(_ news: News) {
        var readingList = getAllReadingListItems()
        readingList.removeAll { $0.articleId == news.articleId }
        saveReadingList(readingList)
        // Invalidate cache to ensure fresh data on next read
        cachedReadingList = nil
        cacheTimestamp = nil
        // Notify subscribers about the change
        readingListDidChange.send()
    }
    
    func isInReadingList(_ news: News) -> Bool {
        guard let articleId = news.articleId else { return false }
        let readingList = getAllReadingListItems()
        return readingList.contains { $0.articleId == articleId }
    }
    
    func getAllReadingListItems() -> [News] {
        // Cache kontrolü - ama cache invalidate edilmişse (nil) her zaman fresh data çek
        if let cached = cachedReadingList,
           let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) < cacheValidityDuration {
            return cached
        }
        
        guard let data = userDefaults.data(forKey: readingListKey) else {
            cachedReadingList = []
            cacheTimestamp = Date()
            return []
        }
        
        guard let readingList = try? JSONDecoder().decode([News].self, from: data) else {
            cachedReadingList = []
            cacheTimestamp = Date()
            return []
        }
        
        cachedReadingList = readingList
        cacheTimestamp = Date()
        return readingList
    }
    
    private func saveReadingList(_ readingList: [News]) {
        if let encoded = try? JSONEncoder().encode(readingList) {
            userDefaults.set(encoded, forKey: readingListKey)
            cachedReadingList = readingList
            cacheTimestamp = Date()
        }
    }
}

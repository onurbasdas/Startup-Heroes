//
//  ReadingListManager.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation

protocol ReadingListManagerProtocol {
    func addToReadingList(_ news: News)
    func removeFromReadingList(_ news: News)
    func isInReadingList(_ news: News) -> Bool
    func getAllReadingListItems() -> [News]
}

class ReadingListManager: ReadingListManagerProtocol {
    
    private let userDefaults: UserDefaults
    private let readingListKey = Constants.readingListKey
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func addToReadingList(_ news: News) {
        var readingList = getAllReadingListItems()
        
        if !isInReadingList(news) {
            readingList.append(news)
            saveReadingList(readingList)
            debugPrint("DEBUG - News added to reading list: \(news.title ?? "Unknown")")
        }
    }
    
    func removeFromReadingList(_ news: News) {
        var readingList = getAllReadingListItems()
        readingList.removeAll { $0.articleId == news.articleId }
        saveReadingList(readingList)
        debugPrint("DEBUG - News removed from reading list: \(news.title ?? "Unknown")")
    }
    
    func isInReadingList(_ news: News) -> Bool {
        guard let articleId = news.articleId else { return false }
        let readingList = getAllReadingListItems()
        return readingList.contains { $0.articleId == articleId }
    }
    
    func getAllReadingListItems() -> [News] {
        guard let data = userDefaults.data(forKey: readingListKey),
              let readingList = try? JSONDecoder().decode([News].self, from: data) else {
            return []
        }
        return readingList
    }
    
    private func saveReadingList(_ readingList: [News]) {
        if let encoded = try? JSONEncoder().encode(readingList) {
            userDefaults.set(encoded, forKey: readingListKey)
        }
    }
}

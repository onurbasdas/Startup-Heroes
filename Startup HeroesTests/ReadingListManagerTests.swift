//
//  ReadingListManagerTests.swift
//  Startup HeroesTests
//
//  Created by Onur Basdas on 7.12.2025.
//

import Testing
import Foundation
@testable import Startup_Heroes

/// ReadingListManager için unit testler
/// Okuma listesi işlemlerinin doğru çalıştığını ve kalıcılığını test eder
struct ReadingListManagerTests {
    
    /// Haber ekleme testi
    @Test func testAddToReadingList() throws {
        // Given
        let mockUserDefaults = MockUserDefaults()
        let manager = ReadingListManager(userDefaults: mockUserDefaults)
        let news = createTestNews(id: "test-1", title: "Test News 1")
        
        // When
        manager.addToReadingList(news)
        
        // Then
        #expect(manager.isInReadingList(news) == true)
        let allItems = manager.getAllReadingListItems()
        #expect(allItems.count == 1)
        #expect(allItems.first?.articleId == "test-1")
    }
    
    /// Haber çıkarma testi
    @Test func testRemoveFromReadingList() throws {
        // Given
        let mockUserDefaults = MockUserDefaults()
        let manager = ReadingListManager(userDefaults: mockUserDefaults)
        let news1 = createTestNews(id: "test-1", title: "Test News 1")
        let news2 = createTestNews(id: "test-2", title: "Test News 2")
        
        manager.addToReadingList(news1)
        manager.addToReadingList(news2)
        
        // When
        manager.removeFromReadingList(news1)
        
        // Then
        #expect(manager.isInReadingList(news1) == false)
        #expect(manager.isInReadingList(news2) == true)
        let allItems = manager.getAllReadingListItems()
        #expect(allItems.count == 1)
        #expect(allItems.first?.articleId == "test-2")
    }
    
    /// Aynı haberin tekrar eklenmemesi testi
    @Test func testAddDuplicateNews() throws {
        // Given
        let mockUserDefaults = MockUserDefaults()
        let manager = ReadingListManager(userDefaults: mockUserDefaults)
        let news = createTestNews(id: "test-1", title: "Test News 1")
        
        // When
        manager.addToReadingList(news)
        manager.addToReadingList(news) // Tekrar ekle
        
        // Then
        let allItems = manager.getAllReadingListItems()
        #expect(allItems.count == 1) // Sadece bir tane olmalı
    }
    
    /// Liste kontrolü testi
    @Test func testIsInReadingList() throws {
        // Given
        let mockUserDefaults = MockUserDefaults()
        let manager = ReadingListManager(userDefaults: mockUserDefaults)
        let news1 = createTestNews(id: "test-1", title: "Test News 1")
        let news2 = createTestNews(id: "test-2", title: "Test News 2")
        
        manager.addToReadingList(news1)
        
        // When & Then
        #expect(manager.isInReadingList(news1) == true)
        #expect(manager.isInReadingList(news2) == false)
    }
    
    /// Boş liste testi
    @Test func testEmptyReadingList() throws {
        // Given
        let mockUserDefaults = MockUserDefaults()
        let manager = ReadingListManager(userDefaults: mockUserDefaults)
        
        // When
        let allItems = manager.getAllReadingListItems()
        
        // Then
        #expect(allItems.isEmpty == true)
    }
    
    /// Kalıcılık testi - Yeni manager instance'ı ile aynı verileri okuma
    @Test func testPersistence() throws {
        // Given
        let mockUserDefaults = MockUserDefaults()
        let news = createTestNews(id: "test-1", title: "Test News 1")
        
        // When - İlk manager ile ekle
        let manager1 = ReadingListManager(userDefaults: mockUserDefaults)
        manager1.addToReadingList(news)
        
        // Then - Yeni manager ile kontrol et
        let manager2 = ReadingListManager(userDefaults: mockUserDefaults)
        #expect(manager2.isInReadingList(news) == true)
        let allItems = manager2.getAllReadingListItems()
        #expect(allItems.count == 1)
    }
    
    /// ArticleId olmayan haber testi
    @Test func testNewsWithoutArticleId() throws {
        // Given
        let mockUserDefaults = MockUserDefaults()
        let manager = ReadingListManager(userDefaults: mockUserDefaults)
        let news = createTestNews(id: nil, title: "Test News")
        
        // When
        manager.addToReadingList(news)
        
        // Then - ArticleId olmayan haber eklenemez
        #expect(manager.isInReadingList(news) == false)
    }
    
    // MARK: - Helper Methods
    private func createTestNews(id: String?, title: String) -> News {
        return News(
            articleId: id,
            title: title,
            link: "https://test.com",
            keywords: nil,
            creator: ["Test Author"],
            videoUrl: nil,
            description: "Test description",
            content: "Test content",
            pubDate: "2025-12-07",
            imageUrl: "https://test.com/image.jpg",
            sourceId: nil,
            sourcePriority: nil,
            sourceUrl: nil,
            sourceIcon: nil,
            language: "en",
            country: nil,
            category: nil
        )
    }
}

/// Mock UserDefaults - Test için UserDefaults mock'u
class MockUserDefaults: UserDefaults {
    private var storage: [String: Any] = [:]
    
    override func data(forKey defaultName: String) -> Data? {
        return storage[defaultName] as? Data
    }
    
    override func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }
    
    override func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }
}


//
//  NewsAPIServiceTests.swift
//  Startup HeroesTests
//
//  Created by Onur Basdas on 7.12.2025.
//

import Testing
import Foundation
@testable import Startup_Heroes

/// NewsAPIService için unit testler
/// API servisinin doğru çalıştığını ve JSON parsing'in doğru yapıldığını test eder
@MainActor
struct NewsAPIServiceTests {
    
    /// Başarılı haber çekme testi
    @Test func testFetchNewsSuccess() async throws {
        // Given
        let mockNewsResponse = NewsResponse(
            status: "success",
            totalResults: 1,
            results: [
                News(
                    articleId: "test-id",
                    title: "Test News",
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
            ],
            nextPage: nil
        )
        
        let jsonData = try JSONEncoder().encode(mockNewsResponse)
        let mockNetworkService = MockNetworkService(data: jsonData, error: nil)
        let apiService = NewsAPIService(networkService: mockNetworkService, apiKey: "test-api-key")
        
        // When
        let result = await withCheckedContinuation { continuation in
            apiService.fetchNews { response in
                continuation.resume(returning: response)
            }
        }
        
        // Then
        switch result {
        case .success(let newsResponse):
            #expect(newsResponse.status == "success")
            #expect(newsResponse.totalResults == 1)
            #expect(newsResponse.results.count == 1)
            #expect(newsResponse.results.first?.title == "Test News")
        case .failure(let error):
            Issue.record("Fetch should succeed but failed: \(error.localizedDescription)")
        }
    }
    
    /// Network hatası testi
    @Test func testFetchNewsNetworkError() async throws {
        // Given
        let networkError = NetworkError.httpError(statusCode: 500)
        let mockNetworkService = MockNetworkService(data: nil, error: networkError)
        let apiService = NewsAPIService(networkService: mockNetworkService, apiKey: "test-api-key")
        
        // When
        let result = await withCheckedContinuation { continuation in
            apiService.fetchNews { response in
                continuation.resume(returning: response)
            }
        }
        
        // Then
        switch result {
        case .success:
            Issue.record("Fetch should fail but succeeded")
        case .failure(let error):
            #expect(error is NetworkError)
        }
    }
    
    /// Geçersiz JSON testi
    @Test func testFetchNewsInvalidJSON() async throws {
        // Given
        let invalidJSON = "invalid json".data(using: .utf8)!
        let mockNetworkService = MockNetworkService(data: invalidJSON, error: nil)
        let apiService = NewsAPIService(networkService: mockNetworkService, apiKey: "test-api-key")
        
        // When
        let result = await withCheckedContinuation { continuation in
            apiService.fetchNews { response in
                continuation.resume(returning: response)
            }
        }
        
        // Then
        switch result {
        case .success:
            Issue.record("Fetch should fail due to invalid JSON but succeeded")
        case .failure:
            // JSON decode hatası bekleniyor
            break
        }
    }
    
    /// Geçersiz URL testi
    @Test func testFetchNewsInvalidURL() async throws {
        // Given
        let networkError = NetworkError.invalidURL
        let mockNetworkService = MockNetworkService(data: nil, error: networkError)
        let apiService = NewsAPIService(networkService: mockNetworkService, apiKey: "test-api-key")
        
        // When
        let result = await withCheckedContinuation { continuation in
            apiService.fetchNews { response in
                continuation.resume(returning: response)
            }
        }
        
        // Then
        switch result {
        case .success:
            Issue.record("Fetch should fail but succeeded")
        case .failure(let error):
            if let networkError = error as? NetworkError {
                #expect(networkError == .invalidURL)
            } else {
                Issue.record("Expected NetworkError.invalidURL")
            }
        }
    }
}

/// Mock NetworkService - Test için NetworkService mock'u
nonisolated class MockNetworkService: NetworkServiceProtocol {
    private let mockData: Data?
    private let mockError: Error?
    
    init(data: Data?, error: Error?) {
        self.mockData = data
        self.mockError = error
    }
    
    nonisolated func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        Task {
            if let error = self.mockError {
                completion(.failure(error))
            } else if let data = self.mockData {
                completion(.success(data))
            } else {
                completion(.failure(NetworkError.noData))
            }
        }
    }
}


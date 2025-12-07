//
//  NetworkServiceTests.swift
//  Startup HeroesTests
//
//  Created by Onur Basdas on 7.12.2025.
//

import Testing
import Foundation
@testable import Startup_Heroes

/// NetworkService için unit testler
/// Network isteklerinin doğru çalıştığını ve hata durumlarının doğru yönetildiğini test eder
struct NetworkServiceTests {
    
    /// Başarılı network isteği testi
    @Test func testSuccessfulRequest() async throws {
        // Given
        let testData = "Test response data".data(using: .utf8)!
        let mockNetworkService = MockNetworkServiceForTesting(data: testData, error: nil)
        let testURL = URL(string: "https://api.example.com/test")!
        
        // When
        let result = await withCheckedContinuation { continuation in
            mockNetworkService.request(url: testURL) { response in
                continuation.resume(returning: response)
            }
        }
        
        // Then
        switch result {
        case .success(let data):
            #expect(data == testData)
        case .failure:
            Issue.record("Request should succeed but failed")
        }
    }
    
    /// HTTP hata durumu testi (429 - Rate Limit)
    @Test func testHTTPError429() async throws {
        // Given
        let networkError = NetworkError.httpError(statusCode: 429)
        let mockNetworkService = MockNetworkServiceForTesting(data: nil, error: networkError)
        let testURL = URL(string: "https://api.example.com/test")!
        
        // When
        let result = await withCheckedContinuation { continuation in
            mockNetworkService.request(url: testURL) { response in
                continuation.resume(returning: response)
            }
        }
        
        // Then
        switch result {
        case .success:
            Issue.record("Request should fail but succeeded")
        case .failure(let error):
            if let networkError = error as? NetworkError {
                if case .httpError(let statusCode) = networkError {
                    #expect(statusCode == 429)
                } else {
                    Issue.record("Expected HTTP error but got different error type")
                }
            } else {
                Issue.record("Expected NetworkError but got different error type")
            }
        }
    }
    
    /// Geçersiz URL testi
    @Test func testInvalidURL() async throws {
        // Given
        let networkError = NetworkError.invalidURL
        let mockNetworkService = MockNetworkServiceForTesting(data: nil, error: networkError)
        let testURL = URL(string: "https://api.example.com/test")!
        
        // When
        let result = await withCheckedContinuation { continuation in
            mockNetworkService.request(url: testURL) { response in
                continuation.resume(returning: response)
            }
        }
        
        // Then
        switch result {
        case .success:
            Issue.record("Request should fail but succeeded")
        case .failure(let error):
            if let networkError = error as? NetworkError {
                #expect(networkError == .invalidURL)
            } else {
                Issue.record("Expected NetworkError.invalidURL")
            }
        }
    }
}

/// Mock NetworkService - Test için NetworkServiceProtocol mock'u
nonisolated class MockNetworkServiceForTesting: NetworkServiceProtocol {
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


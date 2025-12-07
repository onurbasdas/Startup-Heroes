//
//  NetworkService.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation

/// Network servis protokolü - Test edilebilirlik için
protocol NetworkServiceProtocol {
    func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

/// Network servisi - HTTP isteklerini yönetir
class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Properties
    private let session: URLSession
    
    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Public Methods
    func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
}

/// Network hata tipleri
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case httpError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL"
        case .invalidResponse:
            return "Geçersiz yanıt"
        case .noData:
            return "Veri alınamadı"
        case .httpError(let statusCode):
            return "HTTP hatası: \(statusCode)"
        }
    }
}

//
//  NetworkService.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    nonisolated func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

/// Network servisi - Alamofire kullanarak HTTP isteklerini yönetir
/// Alamofire kullanma sebepleri: Gelişmiş hata yönetimi, request/response interceptor desteği,
/// otomatik retry mekanizması ve daha temiz API sağlar.
nonisolated class NetworkService: NetworkServiceProtocol {
    
    private let session: Session
    
    nonisolated init(session: Session = .default) {
        self.session = session
    }
    
    nonisolated func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        session.request(url, method: .get)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let afError):
                    completion(.failure(Self.mapAFError(afError)))
                }
            }
    }
    
    private static func mapAFError(_ afError: AFError) -> NetworkError {
        switch afError {
        case .invalidURL:
            return .invalidURL
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                return .httpError(statusCode: code)
            }
            return .invalidResponse
        case .responseSerializationFailed:
            return .invalidResponse
        default:
            return .invalidResponse
        }
    }
}

enum NetworkError: Error, LocalizedError, Equatable {
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

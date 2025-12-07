//
//  NetworkService.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation
import Alamofire

/// Network servis protokolü - Test edilebilirlik için
protocol NetworkServiceProtocol {
    func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

/// Network servisi - Alamofire kullanarak HTTP isteklerini yönetir
/// Alamofire kullanma sebebi: Daha iyi hata yönetimi, request/response interceptor desteği,
/// otomatik retry mekanizması ve daha temiz API sağlar.
class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Properties
    private let session: Session
    
    // MARK: - Initialization
    init(session: Session = .default) {
        self.session = session
    }
    
    // MARK: - Public Methods
    func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        session.request(url, method: .get)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let afError):
                    debugPrint("DEBUG - Alamofire request error: \(afError.localizedDescription)")
                    completion(.failure(self.mapAFError(afError)))
                }
            }
    }
    
    // MARK: - Private Methods
    private func mapAFError(_ afError: AFError) -> NetworkError {
        switch afError {
        case .invalidURL(let url):
            debugPrint("DEBUG - Invalid URL: \(url)")
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

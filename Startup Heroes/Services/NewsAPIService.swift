//
//  NewsAPIService.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation
import Alamofire

protocol NewsAPIServiceProtocol {
    func fetchNews(completion: @escaping (Result<NewsResponse, Error>) -> Void)
    func fetchNewsSources(completion: @escaping (Result<NewsSourceResponse, Error>) -> Void)
}

nonisolated class NewsAPIService: NewsAPIServiceProtocol {
    
    private let networkService: NetworkServiceProtocol
    private let apiKey: String
    private let baseURL = "https://newsdata.io/api/1"
    
    nonisolated init(networkService: NetworkServiceProtocol, apiKey: String) {
        self.networkService = networkService
        self.apiKey = apiKey
    }
    
    nonisolated func fetchNews(completion: @escaping (Result<NewsResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/news?apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        networkService.request(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let newsResponse = try decoder.decode(NewsResponse.self, from: data)
                    completion(.success(newsResponse))
                } catch {
                    debugPrint("DEBUG - JSON decode error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                debugPrint("DEBUG - Network request error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    nonisolated func fetchNewsSources(completion: @escaping (Result<NewsSourceResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/sources?apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        networkService.request(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let sourcesResponse = try decoder.decode(NewsSourceResponse.self, from: data)
                    completion(.success(sourcesResponse))
                } catch {
                    debugPrint("DEBUG - JSON decode error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                debugPrint("DEBUG - Network request error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

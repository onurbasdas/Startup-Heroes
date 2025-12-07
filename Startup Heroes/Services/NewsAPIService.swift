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

class NewsAPIService: NewsAPIServiceProtocol {
    
    private let networkService: NetworkServiceProtocol
    private let apiKey: String
    private let baseURL = "https://newsdata.io/api/1"
    
    init(networkService: NetworkServiceProtocol, apiKey: String) {
        self.networkService = networkService
        self.apiKey = apiKey
    }
    
    
    func fetchNews(completion: @escaping (Result<NewsResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/news?apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        networkService.request(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    // Decode on the main actor because the model's Decodable conformance is main-actor isolated
                    let newsResponse = try MainActor.assumeIsolated { () -> NewsResponse in
                        let decoder = JSONDecoder()
                        return try decoder.decode(NewsResponse.self, from: data)
                    }
                    DispatchQueue.main.async {
                        completion(.success(newsResponse))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchNewsSources(completion: @escaping (Result<NewsSourceResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/sources?apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        networkService.request(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    // Decode on the main actor because the model's Decodable conformance is main-actor isolated
                    let sourcesResponse = try MainActor.assumeIsolated { () -> NewsSourceResponse in
                        let decoder = JSONDecoder()
                        return try decoder.decode(NewsSourceResponse.self, from: data)
                    }
                    DispatchQueue.main.async {
                        completion(.success(sourcesResponse))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

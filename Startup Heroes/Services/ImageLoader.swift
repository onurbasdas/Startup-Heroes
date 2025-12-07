//
//  ImageLoader.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit

/// Görsel yükleme servisi protokolü - Test edilebilirlik için
protocol ImageLoaderProtocol {
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
    func cancelLoad(for url: URL)
}

/// Görsel yükleme servisi - Async görsel indirme ve cache
class ImageLoader: ImageLoaderProtocol {
    
    // MARK: - Properties
    static let shared = ImageLoader()
    
    private let session: URLSession
    private var cache: NSCache<NSURL, UIImage>
    private var activeTasks: [URL: URLSessionDataTask] = [:]
    private let queue = DispatchQueue(label: "ImageLoader", attributes: .concurrent)
    
    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.session = session
        self.cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Public Methods
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let nsURL = url as NSURL
        
        // Cache'den kontrol et
        if let cachedImage = cache.object(forKey: nsURL) {
            DispatchQueue.main.async {
                completion(.success(cachedImage))
            }
            return
        }
        
        // Zaten yükleniyorsa iptal et
        cancelLoad(for: url)
        
        // Yeni task oluştur
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            self.queue.async(flags: .barrier) {
                self.activeTasks.removeValue(forKey: url)
            }
            
            if let error = error {
                debugPrint("DEBUG - Image load error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                let noImageError = NSError(domain: "ImageLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Görsel verisi alınamadı"])
                DispatchQueue.main.async {
                    completion(.failure(noImageError))
                }
                return
            }
            
            // Cache'e kaydet
            self.cache.setObject(image, forKey: nsURL)
            
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }
        
        queue.async(flags: .barrier) {
            self.activeTasks[url] = task
        }
        
        task.resume()
    }
    
    func cancelLoad(for url: URL) {
        queue.async(flags: .barrier) {
            if let task = self.activeTasks[url] {
                task.cancel()
                self.activeTasks.removeValue(forKey: url)
            }
        }
    }
}


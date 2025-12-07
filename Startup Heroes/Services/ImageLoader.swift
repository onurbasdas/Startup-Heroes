//
//  ImageLoader.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
    func cancelLoad(for url: URL)
}

class ImageLoader: ImageLoaderProtocol {
    
    static let shared = ImageLoader()
    
    private let session: URLSession
    private var cache: NSCache<NSURL, UIImage>
    private var activeTasks: [URL: URLSessionDataTask] = [:]
    private let queue = DispatchQueue(label: "ImageLoader", attributes: .concurrent)
    
    init(session: URLSession = .shared) {
        self.session = session
        self.cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let nsURL = url as NSURL
        
        if let cachedImage = cache.object(forKey: nsURL) {
            DispatchQueue.main.async {
                completion(.success(cachedImage))
            }
            return
        }
        
        cancelLoad(for: url)
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            self.queue.async(flags: .barrier) {
                self.activeTasks.removeValue(forKey: url)
            }
            
            if let error = error {
                let nsError = error as NSError
                if nsError.code != NSURLErrorCancelled {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                return
            }
            
            guard let data = data else {
                let noImageError = NSError(domain: "ImageLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Görsel verisi alınamadı"])
                DispatchQueue.main.async {
                    completion(.failure(noImageError))
                }
                return
            }
            
            guard let image = UIImage(data: data) else {
                let noImageError = NSError(domain: "ImageLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Görsel verisi alınamadı"])
                DispatchQueue.main.async {
                    completion(.failure(noImageError))
                }
                return
            }
            
            // Fix image format to prevent kCGImageBlockFormatBGRx8 error
            let fixedImage = self.fixImageFormat(image)
            
            self.cache.setObject(fixedImage, forKey: nsURL)
            
            DispatchQueue.main.async {
                completion(.success(fixedImage))
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
    
    private func fixImageFormat(_ image: UIImage) -> UIImage {
        // If image is already in correct format, return as is
        guard let cgImage = image.cgImage else {
            return image
        }
        
        // Check if image needs format conversion
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return image
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let fixedCGImage = context.makeImage() else {
            return image
        }
        
        return UIImage(cgImage: fixedCGImage, scale: image.scale, orientation: image.imageOrientation)
    }
}


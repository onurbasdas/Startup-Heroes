//
//  UIImageView+Extensions.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit
import SnapKit

extension UIImageView {
    
    /// URL'den görsel yükler ve UIImageView'e set eder
    /// - Parameters:
    ///   - urlString: Görsel URL string'i
    ///   - placeholder: Yüklenirken gösterilecek placeholder görsel (opsiyonel)
    ///   - imageLoader: ImageLoader servisi (default: shared instance)
    func loadImage(from urlString: String?, placeholder: UIImage? = nil, imageLoader: ImageLoaderProtocol = ImageLoader.shared) {
        // Placeholder göster
        if let placeholder = placeholder {
            self.image = placeholder
        } else {
            self.image = nil
        }
        
        guard let urlString = urlString, let url = URL(string: urlString) else {
            debugPrint("DEBUG - Invalid image URL: \(urlString ?? "nil")")
            return
        }
        
        imageLoader.loadImage(from: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let image):
                UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
                    self.image = image
                }
            case .failure(let error):
                debugPrint("DEBUG - Failed to load image from \(urlString): \(error.localizedDescription)")
                // Hata durumunda placeholder kalır veya nil olur
            }
        }
    }
    
    /// Aktif görsel yükleme işlemini iptal eder
    func cancelImageLoad(imageLoader: ImageLoaderProtocol = ImageLoader.shared) {
        // Bu metod şimdilik boş, gerekirse URL tracking eklenebilir
    }
}


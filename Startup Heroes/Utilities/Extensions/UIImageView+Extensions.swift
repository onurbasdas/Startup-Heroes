//
//  UIImageView+Extensions.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit

extension UIImageView {
    
    func loadImage(from urlString: String?, placeholder: UIImage? = nil, imageLoader: ImageLoaderProtocol = ImageLoader.shared) {
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
            }
        }
    }
    
}


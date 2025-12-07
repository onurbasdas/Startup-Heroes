//
//  FontManager.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit

struct FontManager {
    
    static func titleFont(size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .bold)
    }
    
    static func bodyFont(size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .regular)
    }
    
    static func bodyFontMedium(size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .medium)
    }
    
    static func bodyFontSemibold(size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .semibold)
    }
    
    static func captionFont(size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .regular)
    }
    
    static let newsTitle: UIFont = titleFont(size: 18)
    static let newsDescription: UIFont = bodyFont(size: 14)
    static let newsCreator: UIFont = captionFont(size: 13)
    static let newsDate: UIFont = captionFont(size: 13)
    
    static let detailTitle: UIFont = titleFont(size: 26)
    static let detailBody: UIFont = bodyFont(size: 17)
    static let detailInfo: UIFont = bodyFontMedium(size: 16)
}


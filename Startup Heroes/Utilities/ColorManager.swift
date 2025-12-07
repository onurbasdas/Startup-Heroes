//
//  ColorManager.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit

struct ColorManager {
    
    static let primaryOrange = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
    static let primaryOrangeLight = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
    static let primaryOrangeDark = UIColor(red: 0.9, green: 0.4, blue: 0.0, alpha: 1.0)
    
    static let backgroundLight = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    static let backgroundSecondary = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    
    static let textPrimary = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    static let textSecondary = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
    
    static let navigationBarBackground = UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 1.0)
    
    static func orangeGradientColors() -> [CGColor] {
        return [
            primaryOrangeLight.cgColor,
            primaryOrange.cgColor,
            primaryOrangeDark.cgColor
        ]
    }
}


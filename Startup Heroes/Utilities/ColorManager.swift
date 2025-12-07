//
//  ColorManager.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit

struct ColorManager {
    
    // Primary Orange - Dark mode'da biraz daha parlak
    static let primaryOrange = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 1.0, green: 0.55, blue: 0.1, alpha: 1.0)
        } else {
            return UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        }
    }
    
    static let primaryOrangeLight = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 1.0, green: 0.65, blue: 0.3, alpha: 1.0)
        } else {
            return UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        }
    }
    
    static let primaryOrangeDark = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 0.95, green: 0.45, blue: 0.05, alpha: 1.0)
        } else {
            return UIColor(red: 0.9, green: 0.4, blue: 0.0, alpha: 1.0)
        }
    }
    
    // Background colors - Dark mode desteği
    static let backgroundLight = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        } else {
            return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        }
    }
    
    static let backgroundSecondary = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        } else {
            return UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        }
    }
    
    // Card background - Dark mode'da koyu gri
    static let cardBackground = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.0)
        } else {
            return .white
        }
    }
    
    // Text colors - Dark mode'da açık renkler
    static let textPrimary = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        } else {
            return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        }
    }
    
    static let textSecondary = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        } else {
            return UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        }
    }
    
    // Navigation bar background
    static let navigationBarBackground = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        } else {
            return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        }
    }
    
    // Shadow color - Dark mode'da daha hafif
    static let shadowColor = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor.black.withAlphaComponent(0.3)
        } else {
            return UIColor.black.withAlphaComponent(0.1)
        }
    }
    
    // Shimmer colors - Dark mode'da daha koyu tonlar
    static let shimmerBase = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 0.4)
        } else {
            return UIColor(red: 1.0, green: 0.85, blue: 0.7, alpha: 0.3)
        }
    }
    
    static let shimmerHighlight = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 0.4, green: 0.35, blue: 0.3, alpha: 0.6)
        } else {
            return UIColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 0.6)
        }
    }
    
    static func orangeGradientColors() -> [CGColor] {
        return [
            primaryOrangeLight.cgColor,
            primaryOrange.cgColor,
            primaryOrangeDark.cgColor
        ]
    }
    
    static func shimmerGradientColors() -> [CGColor] {
        return [
            shimmerBase.cgColor,
            shimmerHighlight.cgColor,
            shimmerBase.cgColor
        ]
    }
}


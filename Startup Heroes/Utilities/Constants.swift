//
//  Constants.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation

/// Uygulama sabitleri
enum Constants {
    /// NewsData API anahtarı - Info.plist'ten okunur
    static var newsAPIKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "NewsAPIKey") as? String else {
            fatalError("NewsAPIKey bulunamadı. Info.plist dosyasını kontrol edin.")
        }
        return apiKey
    }
    
    /// API yenileme aralığı (saniye cinsinden - 60 saniye = 1 dakika)
    static let newsRefreshInterval: TimeInterval = 60
    
    /// Alert gösterim süresi (saniye cinsinden)
    static let alertDisplayDuration: TimeInterval = 1.0
    
    /// Reading List UserDefaults anahtarı
    static let readingListKey = "ReadingList"
    
    /// News Cache TTL (saniye cinsinden - 3600 saniye = 1 saat)
    static let newsCacheTTL: TimeInterval = 3600
}

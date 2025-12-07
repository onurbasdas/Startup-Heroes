//
//  Constants.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation

/// Uygulama sabitleri
enum Constants {
    /// NewsData API anahtarı - Production'da güvenli şekilde saklanmalı
    static let newsAPIKey = "YOUR_API_KEY_HERE"
    
    /// API yenileme aralığı (saniye cinsinden - 60 saniye = 1 dakika)
    static let newsRefreshInterval: TimeInterval = 60
    
    /// Alert gösterim süresi (saniye cinsinden)
    static let alertDisplayDuration: TimeInterval = 1.0
    
    /// Reading List UserDefaults anahtarı
    static let readingListKey = "ReadingList"
}

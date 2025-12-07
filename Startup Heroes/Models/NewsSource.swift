//
//  NewsSource.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation

/// Haber kaynağı modeli
struct NewsSource: Codable {
    let id: String
    let name: String
    let description: String?
    let url: String?
    let category: String?
    let language: String?
    let country: String?
}

/// Haber kaynakları API yanıt modeli
struct NewsSourceResponse: Codable {
    let status: String
    let sources: [NewsSource]
}

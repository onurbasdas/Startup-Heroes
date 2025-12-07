//
//  News.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation

/// Haber modeli - NewsData API'den gelen haber verilerini temsil eder
struct News: Codable {
    let articleId: String?
    let title: String?
    let link: String?
    let keywords: [String]?
    let creator: [String]?
    let videoUrl: String?
    let description: String?
    let content: String?
    let pubDate: String?
    let imageUrl: String?
    let sourceId: String?
    let sourcePriority: Int?
    let sourceUrl: String?
    let sourceIcon: String?
    let language: String?
    let country: [String]?
    let category: [String]?
    
    enum CodingKeys: String, CodingKey {
        case articleId = "article_id"
        case title
        case link
        case keywords
        case creator
        case videoUrl = "video_url"
        case description
        case content
        case pubDate = "pubDate"
        case imageUrl = "image_url"
        case sourceId = "source_id"
        case sourcePriority = "source_priority"
        case sourceUrl = "source_url"
        case sourceIcon = "source_icon"
        case language
        case country
        case category
    }
}

/// NewsData API yanıt modeli
struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let results: [News]
    let nextPage: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case totalResults = "totalResults"
        case results
        case nextPage = "nextPage"
    }
}

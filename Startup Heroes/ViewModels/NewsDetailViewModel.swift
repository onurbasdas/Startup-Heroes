//
//  NewsDetailViewModel.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation

class NewsDetailViewModel {
    
    let news: News
    
    init(news: News) {
        self.news = news
    }
    
    var title: String? {
        return news.title
    }
    
    var creator: String {
        return news.creator?.joined(separator: ", ") ?? "Bilinmiyor"
    }
    
    var pubDate: String {
        return news.pubDate?.formattedDate() ?? news.pubDate ?? "Bilinmiyor"
    }
    
    var description: String? {
        return news.description
    }
    
    var content: String? {
        return news.content ?? news.description
    }
    
    var imageUrl: URL? {
        guard let imageUrlString = news.imageUrl else { return nil }
        return URL(string: imageUrlString)
    }
}


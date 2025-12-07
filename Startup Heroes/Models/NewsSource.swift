//
//  NewsSource.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation

struct NewsSource: Codable, Sendable {
    let id: String
    let name: String
    let description: String?
    let url: String?
    let category: String?
    let language: String?
    let country: String?
}

struct NewsSourceResponse: Codable, Sendable {
    let status: String
    let sources: [NewsSource]
}

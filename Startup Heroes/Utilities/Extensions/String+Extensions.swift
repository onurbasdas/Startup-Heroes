//
//  String+Extensions.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation

extension String {
    /// API'den gelen tarih string'ini okunabilir formata çevirir
    func formattedDate() -> String? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: self) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            displayFormatter.locale = Locale(identifier: "tr_TR")
            return displayFormatter.string(from: date)
        }
        
        // Alternatif format dene
        let alternativeFormatter = DateFormatter()
        alternativeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = alternativeFormatter.date(from: self) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            displayFormatter.locale = Locale(identifier: "tr_TR")
            return displayFormatter.string(from: date)
        }
        
        return nil
    }
}

//
//  ReadingListViewModel.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation

class ReadingListViewModel: BaseViewModel {
    
    var onReadingListUpdated: (([News]) -> Void)?
    
    private let readingListManager: ReadingListManagerProtocol
    
    init(readingListManager: ReadingListManagerProtocol) {
        self.readingListManager = readingListManager
    }
    
    func loadReadingList() {
        let items = readingListManager.getAllReadingListItems()
        onReadingListUpdated?(items)
    }
    
    func removeFromReadingList(_ news: News) {
        readingListManager.removeFromReadingList(news)
        loadReadingList()
    }
    
    func isInReadingList(_ news: News) -> Bool {
        return readingListManager.isInReadingList(news)
    }
}


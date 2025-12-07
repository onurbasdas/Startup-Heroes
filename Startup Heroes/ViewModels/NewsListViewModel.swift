//
//  NewsListViewModel.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation

class NewsListViewModel: BaseViewModel {
    
    var onNewsUpdated: (([News]) -> Void)?
    var onError: ((String) -> Void)?
    var onNewHeadlinesAdded: (() -> Void)?
    var onNetworkStatusChanged: ((Bool) -> Void)?
    
    private var newsItems: [News] = [] {
        didSet {
            filterNews()
        }
    }
    
    private var filteredNewsItems: [News] = [] {
        didSet {
            onNewsUpdated?(filteredNewsItems)
        }
    }
    
    private var searchText: String = "" {
        didSet {
            filterNews()
        }
    }
    
    private var lastScrollOffset: CGFloat = 0
    nonisolated(unsafe) private var refreshTimer: Timer?
    
    private let newsAPIService: NewsAPIServiceProtocol
    private let readingListManager: ReadingListManagerProtocol
    private let networkMonitor: NetworkMonitorProtocol
    init(
        newsAPIService: NewsAPIServiceProtocol,
        readingListManager: ReadingListManagerProtocol,
        networkMonitor: NetworkMonitorProtocol
    ) {
        self.newsAPIService = newsAPIService
        self.readingListManager = readingListManager
        self.networkMonitor = networkMonitor
    }
    
    func startNetworkMonitoring() {
        setupNetworkMonitoring()
        startPeriodicRefresh()
    }
    
    func startPeriodicRefresh() {
        stopPeriodicRefresh()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: Constants.newsRefreshInterval, repeats: true) { [weak self] _ in
            guard let self = self, self.networkMonitor.isConnected else { return }
            self.fetchNews()
        }
    }
    
    func stopPeriodicRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    nonisolated deinit {
        refreshTimer?.invalidate()
        refreshTimer = nil
        networkMonitor.stopMonitoring()
    }
    
    func fetchNews() {
        guard networkMonitor.isConnected else {
            Task { @MainActor in
                self.setLoading(false)
            }
            onError?("İnternet bağlantısı yok. Bağlantı kurulduğunda haberler otomatik yüklenecek.")
            return
        }
        
        Task { @MainActor in
            self.setLoading(true)
        }
        
        let previousCount = newsItems.count
        let shouldShowAlert = previousCount > 0 && lastScrollOffset > 0
        
        newsAPIService.fetchNews { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                Task { @MainActor in
                    self.setLoading(false)
                }
                
                switch result {
                case .success(let response):
                    self.newsItems = response.results
                    
                    if shouldShowAlert && self.newsItems.count > previousCount {
                        self.onNewHeadlinesAdded?()
                    }
                    
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    func searchNews(text: String) {
        searchText = text
    }
    
    func isSearching() -> Bool {
        return !searchText.isEmpty
    }
    
    func getDisplayedNews() -> [News] {
        return filteredNewsItems
    }
    
    func isInReadingList(_ news: News) -> Bool {
        return readingListManager.isInReadingList(news)
    }
    
    func toggleReadingList(for news: News) {
        if readingListManager.isInReadingList(news) {
            readingListManager.removeFromReadingList(news)
        } else {
            readingListManager.addToReadingList(news)
        }
        onNewsUpdated?(filteredNewsItems)
    }
    
    func saveScrollPosition(_ offset: CGFloat) {
        lastScrollOffset = offset
    }
    
    func getScrollPosition() -> CGFloat {
        return lastScrollOffset
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.onConnectionChange { [weak self] isConnected in
            guard let self = self else { return }
            self.onNetworkStatusChanged?(isConnected)
            
            if isConnected {
                self.fetchNews()
            }
        }
    }
    
    private func filterNews() {
        if searchText.isEmpty {
            filteredNewsItems = newsItems
        } else {
            filteredNewsItems = newsItems.filter { news in
                let titleMatch = news.title?.lowercased().contains(searchText.lowercased()) ?? false
                let descriptionMatch = news.description?.lowercased().contains(searchText.lowercased()) ?? false
                return titleMatch || descriptionMatch
            }
        }
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError,
           case .httpError(let statusCode) = networkError,
           statusCode == 429 {
            onError?("API limit aşıldı. Lütfen birkaç dakika sonra tekrar deneyin. (Günlük 200 request limiti)")
        } else {
            onError?("Haberler yüklenirken bir hata oluştu: \(error.localizedDescription)")
        }
    }
}


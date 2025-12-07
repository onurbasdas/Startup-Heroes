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
    private let newsCacheManager: NewsCacheManagerProtocol
    
    // Reading list cache for performance
    private var cachedReadingListArticleIds: Set<String> = []
    private var readingListCacheTimestamp: Date?
    private let readingListCacheValidityDuration: TimeInterval = 5.0 // 5 saniye cache validity
    
    init(
        newsAPIService: NewsAPIServiceProtocol,
        readingListManager: ReadingListManagerProtocol,
        networkMonitor: NetworkMonitorProtocol,
        newsCacheManager: NewsCacheManagerProtocol
    ) {
        self.newsAPIService = newsAPIService
        self.readingListManager = readingListManager
        self.networkMonitor = networkMonitor
        self.newsCacheManager = newsCacheManager
        super.init()
        refreshReadingListCache()
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
    
    deinit {
        refreshTimer?.invalidate()
        refreshTimer = nil
        // Use nonisolated method directly to avoid self capture in deinit
        networkMonitor.stopMonitoring()
    }
    
    func fetchNews(appendMode: Bool = false) {
        if !appendMode {
            if let cachedNews = newsCacheManager.getCachedNews(), newsCacheManager.isCacheValid() {
                newsItems = cachedNews
                Task { @MainActor in
                    self.setLoading(false)
                }
            }
        }
        
        guard networkMonitor.isConnected else {
            if newsItems.isEmpty {
                Task { @MainActor in
                    self.setLoading(false)
                }
                onError?("İnternet bağlantısı yok. Bağlantı kurulduğunda haberler otomatik yüklenecek.")
            }
            return
        }
        
        let previousCount = newsItems.count
        let existingArticleIds = Set(newsItems.compactMap { $0.articleId })
        let shouldShowAlert = previousCount > 0 && lastScrollOffset > 0
        
        if !appendMode || newsItems.isEmpty {
            Task { @MainActor in
                self.setLoading(true)
            }
        }
        
        newsAPIService.fetchNews { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if appendMode && !self.newsItems.isEmpty {
                        let newNews = response.results.filter { news in
                            guard let articleId = news.articleId else { return false }
                            return !existingArticleIds.contains(articleId)
                        }
                        
                        if !newNews.isEmpty {
                            Task { @MainActor in
                                self.setLoading(false)
                            }
                            self.newsItems.append(contentsOf: newNews)
                            if shouldShowAlert {
                                self.onNewHeadlinesAdded?()
                            }
                        }
                    } else {
                        Task { @MainActor in
                            self.setLoading(false)
                        }
                        self.newsItems = response.results
                        self.newsCacheManager.saveNews(response.results)
                        
                        if shouldShowAlert && self.newsItems.count > previousCount {
                            self.onNewHeadlinesAdded?()
                        }
                    }
                    
                case .failure(let error):
                    Task { @MainActor in
                        self.setLoading(false)
                    }
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
        guard let articleId = news.articleId else { return false }
        
        // Her zaman fresh data kullan (cache validity duration 0.0 olduğu için)
        // Ama performans için cache'i kullan, sadece cache geçersizse refresh et
        if let timestamp = readingListCacheTimestamp,
           Date().timeIntervalSince(timestamp) < readingListCacheValidityDuration {
            return cachedReadingListArticleIds.contains(articleId)
        }
        
        // Cache geçersiz veya yok, fresh data çek
        refreshReadingListCache()
        return cachedReadingListArticleIds.contains(articleId)
    }
    
    func toggleReadingList(for news: News) {
        if isInReadingList(news) {
            readingListManager.removeFromReadingList(news)
        } else {
            readingListManager.addToReadingList(news)
        }
        // Cache'i invalidate et
        refreshReadingListCacheInternal()
        // onNewsUpdated çağrılmayacak - sadece ilgili cell reload edilecek
    }
    
    func refreshReadingListCache() {
        // Force invalidate cache timestamp to ensure fresh data is fetched
        readingListCacheTimestamp = nil
        
        // Fetch fresh data from ReadingListManager
        let readingList = readingListManager.getAllReadingListItems()
        let newArticleIds = Set(readingList.compactMap { $0.articleId })
        
        // Update cache and timestamp
        cachedReadingListArticleIds = newArticleIds
        readingListCacheTimestamp = Date()
    }
    
    private func refreshReadingListCacheInternal() {
        refreshReadingListCache()
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
            stopPeriodicRefresh()
            
            if newsItems.isEmpty, let cachedNews = newsCacheManager.getCachedNews() {
                newsItems = cachedNews
            }
            
            onError?("API limit aşıldı. Cache'den haberler gösteriliyor. (Günlük 200 request limiti)")
        } else {
            if newsItems.isEmpty, let cachedNews = newsCacheManager.getCachedNews() {
                newsItems = cachedNews
            }
            onError?("Haberler yüklenirken bir hata oluştu: \(error.localizedDescription)")
        }
    }
}


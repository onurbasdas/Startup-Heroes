//
//  NewsListViewController.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit
import SnapKit

/// Haber listesi view controller
class NewsListViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var newsItems: [News] = []
    private var filteredNewsItems: [News] = []
    private var isSearching = false
    
    private var refreshTimer: Timer?
    private var lastScrollOffset: CGFloat = 0
    
    // Dependencies
    private let newsAPIService: NewsAPIServiceProtocol
    private let readingListManager: ReadingListManagerProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    // MARK: - Initialization
    init(
        newsAPIService: NewsAPIServiceProtocol,
        readingListManager: ReadingListManagerProtocol,
        networkMonitor: NetworkMonitorProtocol
    ) {
        self.newsAPIService = newsAPIService
        self.readingListManager = readingListManager
        self.networkMonitor = networkMonitor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        setupNetworkMonitoring()
        fetchNews()
        startPeriodicRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Detaydan geri geldiğinde haberleri yenile
        fetchNews()
    }
    
    deinit {
        refreshTimer?.invalidate()
        networkMonitor.stopMonitoring()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "News"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.rowHeight = 120
        tableView.separatorStyle = .singleLine
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search news..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.onConnectionChange { [weak self] isConnected in
            guard let self = self else { return }
            if isConnected {
                debugPrint("DEBUG - Network connected, fetching news...")
                self.fetchNews()
            } else {
                debugPrint("DEBUG - Network disconnected, pausing API calls")
                self.showError(message: "İnternet bağlantısı yok. Bağlantı kurulduğunda haberler otomatik yüklenecek.")
            }
        }
    }
    
    // MARK: - Network Methods
    private func fetchNews() {
        guard networkMonitor.isConnected else {
            debugPrint("DEBUG - No network connection, skipping fetch")
            return
        }
        
        // Scroll pozisyonunu kaydet
        lastScrollOffset = tableView.contentOffset.y
        
        newsAPIService.fetchNews { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let previousCount = self.newsItems.count
                    self.newsItems = response.results
                    
                    // Yeni haberler eklendiyse ve kullanıcı en üstte değilse alert göster
                    if previousCount > 0 && self.newsItems.count > previousCount && self.lastScrollOffset > 0 {
                        self.showNewHeadlinesAlert()
                    }
                    
                    // Scroll pozisyonunu koru
                    self.restoreScrollPosition()
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    debugPrint("DEBUG - Failed to fetch news: \(error.localizedDescription)")
                    self.showError(message: "Haberler yüklenirken bir hata oluştu: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func restoreScrollPosition() {
        if lastScrollOffset > 0 {
            tableView.setContentOffset(CGPoint(x: 0, y: lastScrollOffset), animated: false)
        }
    }
    
    private func startPeriodicRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: Constants.newsRefreshInterval, repeats: true) { [weak self] _ in
            self?.fetchNews()
        }
    }
    
    // MARK: - Helper Methods
    private func showNewHeadlinesAlert() {
        let alert = UIAlertController(title: "New headlines added", message: nil, preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.alertDisplayDuration) {
            alert.dismiss(animated: true)
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func filterNews(with searchText: String) {
        if searchText.isEmpty {
            filteredNewsItems = newsItems
        } else {
            filteredNewsItems = newsItems.filter { news in
                let titleMatch = news.title?.lowercased().contains(searchText.lowercased()) ?? false
                let descriptionMatch = news.description?.lowercased().contains(searchText.lowercased()) ?? false
                return titleMatch || descriptionMatch
            }
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension NewsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredNewsItems.count : newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        
        let news = isSearching ? filteredNewsItems[indexPath.row] : newsItems[indexPath.row]
        let isInReadingList = readingListManager.isInReadingList(news)
        
        cell.configure(with: news, isInReadingList: isInReadingList)
        cell.onReadingListButtonTapped = { [weak self] news in
            self?.handleReadingListToggle(for: news)
        }
        
        return cell
    }
    
    private func handleReadingListToggle(for news: News) {
        if readingListManager.isInReadingList(news) {
            readingListManager.removeFromReadingList(news)
        } else {
            readingListManager.addToReadingList(news)
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension NewsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let news = isSearching ? filteredNewsItems[indexPath.row] : newsItems[indexPath.row]
        let detailVC = NewsDetailViewController(news: news)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension NewsListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        isSearching = !searchText.isEmpty
        filterNews(with: searchText)
    }
}

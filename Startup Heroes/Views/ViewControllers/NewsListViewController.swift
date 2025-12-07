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
    
    private var displayedNews: [News] = []
    private var lastScrollOffset: CGFloat = 0
    private var isFirstAppearance = true
    
    // ViewModel
    private let viewModel: NewsListViewModel
    
    // MARK: - Initialization
    init(viewModel: NewsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "News"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupUI()
        setupSearchBar()
        setupViewModelBindings()
        viewModel.startNetworkMonitoring()
        viewModel.fetchNews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstAppearance {
            isFirstAppearance = false
            return
        }
        
        viewModel.fetchNews()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search news..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupViewModelBindings() {
        viewModel.onNewsUpdated = { [weak self] news in
            guard let self = self else { return }
            self.displayedNews = news
            self.restoreScrollPosition()
            self.tableView.reloadData()
        }
        
        viewModel.onError = { [weak self] message in
            guard let self = self else { return }
            self.showError(message: message)
        }
        
        viewModel.onNewHeadlinesAdded = { [weak self] in
            guard let self = self else { return }
            self.showNewHeadlinesAlert()
        }
        
        viewModel.onNetworkStatusChanged = { [weak self] isConnected in
            guard let self = self else { return }
            if !isConnected {
                self.showError(message: "İnternet bağlantısı yok. Bağlantı kurulduğunda haberler otomatik yüklenecek.")
            }
        }
    }
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
    
    private func restoreScrollPosition() {
        let savedOffset = viewModel.getScrollPosition()
        if savedOffset > 0 {
            tableView.setContentOffset(CGPoint(x: 0, y: savedOffset), animated: false)
        }
    }
}

// MARK: - UITableViewDataSource
extension NewsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        
        let news = displayedNews[indexPath.row]
        let isInReadingList = viewModel.isInReadingList(news)
        
        cell.configure(with: news, isInReadingList: isInReadingList)
        cell.onReadingListButtonTapped = { [weak self] news in
            self?.viewModel.toggleReadingList(for: news)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let news = displayedNews[indexPath.row]
        let viewModel = NewsDetailViewModel(news: news)
        let detailVC = NewsDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        viewModel.saveScrollPosition(scrollView.contentOffset.y)
    }
}

// MARK: - UISearchResultsUpdating
extension NewsListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel.searchNews(text: searchText)
    }
}

//
//  NewsListViewController.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit
import SnapKit

/// Haber listesi view controller
class NewsListViewController: BaseViewController {
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        imageView.tintColor = ColorManager.primaryOrange
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emptyStateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Üzgünüz, limiti aştınız :("
        label.font = FontManager.titleFont(size: 22)
        label.textColor = ColorManager.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let emptyStateMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "API günlük istek limitine ulaştı. Lütfen daha sonra tekrar deneyin."
        label.font = FontManager.bodyFont(size: 16)
        label.textColor = ColorManager.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Tekrar Dene", for: .normal)
        button.titleLabel?.font = FontManager.bodyFontMedium(size: 17)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ColorManager.primaryOrange
        button.layer.cornerRadius = 12
        return button
    }()
    
    private var displayedNews: [News] = []
    private var lastScrollOffset: CGFloat = 0
    private var isFirstAppearance = true
    
    private let viewModel: NewsListViewModel
    private let readingListManager: ReadingListManagerProtocol
    
    init(viewModel: NewsListViewModel, readingListManager: ReadingListManagerProtocol) {
        self.viewModel = viewModel
        self.readingListManager = readingListManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "News"
        setupNavigationBar()
        setupRightBarButton()
        
        setupUI()
        setupSearchBar()
        setupViewModelBindings()
        viewModel.startNetworkMonitoring()
        viewModel.fetchNews()
    }
    
    private func setupRightBarButton() {
        let favoriteButton = UIButton(type: .system)
        favoriteButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        favoriteButton.tintColor = ColorManager.primaryOrange
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
    }
    
    @objc private func favoriteButtonTapped() {
        let readingListViewModel = ReadingListViewModel(readingListManager: readingListManager)
        let readingListVC = ReadingListViewController(viewModel: readingListViewModel)
        let navController = UINavigationController(rootViewController: readingListVC)
        navController.modalPresentationStyle = .pageSheet
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
        
        if isFirstAppearance {
            isFirstAppearance = false
            return
        }
        
        viewModel.fetchNews()
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        navigationBar.prefersLargeTitles = false
        navigationBar.isTranslucent = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ColorManager.backgroundLight
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
    
    
    private func setupUI() {
        view.backgroundColor = ColorManager.backgroundLight
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.estimatedRowHeight = 180
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = ColorManager.backgroundLight
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.showsVerticalScrollIndicator = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = ColorManager.primaryOrange
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateTitleLabel)
        emptyStateView.addSubview(emptyStateMessageLabel)
        emptyStateView.addSubview(retryButton)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        emptyStateImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        emptyStateTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyStateImageView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
        }
        
        emptyStateMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyStateTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
        }
        
        retryButton.snp.makeConstraints { make in
            make.top.equalTo(emptyStateMessageLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
        
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    }
    
    @objc private func retryButtonTapped() {
        retryButton.isEnabled = false
        showLoading()
        viewModel.fetchNews()
    }
    
    @objc private func refreshNews() {
        viewModel.fetchNews()
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
            self.tableView.refreshControl?.endRefreshing()
            self.hideLoading()
            self.retryButton.isEnabled = true
            self.updateEmptyState(show: news.isEmpty)
        }
        
        viewModel.onError = { [weak self] message in
            guard let self = self else { return }
            self.tableView.refreshControl?.endRefreshing()
            self.hideLoading()
            self.retryButton.isEnabled = true
            
            if self.displayedNews.isEmpty {
                self.updateEmptyState(show: true, isError: true)
            } else {
                self.showError(message: message)
            }
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
        
        viewModel.onLoadingChanged = { [weak self] isLoading in
            guard let self = self else { return }
            if isLoading {
                self.showLoading()
            } else {
                self.hideLoading()
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
    
    private func updateEmptyState(show: Bool, isError: Bool = false) {
        emptyStateView.isHidden = !show
        tableView.isHidden = show
        
        if show {
            navigationItem.searchController = nil
        } else {
            navigationItem.searchController = searchController
        }
        
        if isError {
            emptyStateImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            emptyStateTitleLabel.text = "Üzgünüz, limiti aştınız :("
            emptyStateMessageLabel.text = "API günlük istek limitine ulaştı. Lütfen daha sonra tekrar deneyin."
            retryButton.isHidden = false
        } else if show {
            emptyStateImageView.image = UIImage(systemName: "newspaper")
            emptyStateTitleLabel.text = "Henüz haber yok"
            emptyStateMessageLabel.text = "Haberler yükleniyor..."
            retryButton.isHidden = true
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

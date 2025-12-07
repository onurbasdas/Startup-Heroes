//
//  NewsListViewController.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit
import SnapKit
import Combine

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
        button.setTitleColor(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .white
        }, for: .normal)
        button.backgroundColor = ColorManager.primaryOrange
        button.layer.cornerRadius = 12
        return button
    }()
    
    private var displayedNews: [News] = []
    private var lastScrollOffset: CGFloat = 0
    private var isFirstAppearance = true
    private var isHandlingButtonTap = false
    
    private let viewModel: NewsListViewModel
    private let readingListManager: ReadingListManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
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
        
        setupUI()
        setupSearchBar()
        setupViewModelBindings()
        setupReadingListObserver()
        viewModel.startNetworkMonitoring()
        viewModel.fetchNews()
    }
    
    private func setupReadingListObserver() {
        // Observe reading list changes from ReadingListManager
        // Only refresh when changes come from ReadingListViewController (modal dismiss)
        // Changes within NewsListViewController are handled locally via cell.updateReadingListButton
        if let readingListManager = readingListManager as? ReadingListManager {
            readingListManager.readingListDidChange
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    // Skip refresh if we're currently handling a button tap in NewsListViewController
                    // The button tap already updates the cell locally, no need to reload all cells
                    if self.isHandlingButtonTap {
                        return
                    }
                    
                    // This change came from ReadingListViewController, refresh cache and reload cells
                    self.viewModel.refreshReadingListCache()
                    
                    if let visibleIndexPaths = self.tableView.indexPathsForVisibleRows, !visibleIndexPaths.isEmpty {
                        self.tableView.reloadRows(at: visibleIndexPaths, with: .none)
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup button after navigation bar is fully laid out to avoid constraint conflicts
        setupRightBarButton()
    }
    
    private func setupRightBarButton() {
        let favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: "bookmark.fill"),
            style: .plain,
            target: self,
            action: #selector(favoriteButtonTapped)
        )
        favoriteButton.tintColor = ColorManager.primaryOrange
        navigationItem.rightBarButtonItem = favoriteButton
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
        
        // Reading list changes are handled by Combine publisher, no need to refresh cache here
        viewModel.fetchNews(appendMode: true)
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
        appearance.titleTextAttributes = [.foregroundColor: ColorManager.textPrimary]
        appearance.largeTitleTextAttributes = [.foregroundColor: ColorManager.textPrimary]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = ColorManager.textPrimary
    }
    
    
    private func setupUI() {
        view.backgroundColor = ColorManager.backgroundLight
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.estimatedRowHeight = 220
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = ColorManager.backgroundLight
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.showsVerticalScrollIndicator = false
        
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
            self.hideLoading()
            self.retryButton.isEnabled = true
            
            let isSearchActive = !(self.searchController.searchBar.text?.isEmpty ?? true)
            let isSearchEmpty = isSearchActive && news.isEmpty
            self.updateEmptyState(show: news.isEmpty, isSearchEmpty: isSearchEmpty)
        }
        
        viewModel.onError = { [weak self] message in
            guard let self = self else { return }
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
    
    private func updateEmptyState(show: Bool, isError: Bool = false, isSearchEmpty: Bool = false) {
        emptyStateView.isHidden = !show
        tableView.isHidden = show
        
        if show && !isSearchEmpty {
            navigationItem.searchController = nil
        } else {
            navigationItem.searchController = searchController
        }
        
        if isError {
            emptyStateImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            emptyStateTitleLabel.text = "Üzgünüz, limiti aştınız :("
            emptyStateMessageLabel.text = "API günlük istek limitine ulaştı. Lütfen daha sonra tekrar deneyin."
            retryButton.isHidden = false
        } else if isSearchEmpty {
            emptyStateImageView.image = UIImage(systemName: "magnifyingglass")
            emptyStateTitleLabel.text = "Sonuç bulunamadı"
            emptyStateMessageLabel.text = "Aradığınız kriterlere uygun haber bulunamadı. Lütfen farklı bir arama terimi deneyin."
            retryButton.isHidden = true
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
            guard let self = self else { return }
            
            // Mark that we're handling a button tap to prevent Combine publisher from reloading all cells
            self.isHandlingButtonTap = true
            
            self.viewModel.toggleReadingList(for: news)
            
            // Sadece button state'ini güncelle, görselleri yeniden yükleme
            let newIsInReadingList = self.viewModel.isInReadingList(news)
            cell.updateReadingListButton(isInReadingList: newIsInReadingList)
            
            // Reset flag after a short delay to allow Combine publisher to process
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isHandlingButtonTap = false
            }
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

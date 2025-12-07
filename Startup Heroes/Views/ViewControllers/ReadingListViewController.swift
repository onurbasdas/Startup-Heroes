//
//  ReadingListViewController.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit
import SnapKit

class ReadingListViewController: BaseViewController {
    
    private let tableView = UITableView()
    private var displayedNews: [News] = []
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bookmark")
        imageView.tintColor = ColorManager.primaryOrange
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emptyStateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Henüz okuma listenizde haber yok"
        label.font = FontManager.titleFont(size: 22)
        label.textColor = ColorManager.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let emptyStateMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Beğendiğiniz haberleri okuma listenize ekleyerek daha sonra okuyabilirsiniz."
        label.font = FontManager.bodyFont(size: 16)
        label.textColor = ColorManager.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let viewModel: ReadingListViewModel
    
    init(viewModel: ReadingListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Reading List"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        
        setupNavigationBar()
        setupUI()
        setupViewModelBindings()
        viewModel.loadReadingList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadReadingList()
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
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
        tableView.estimatedRowHeight = 180
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
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupViewModelBindings() {
        viewModel.onReadingListUpdated = { [weak self] news in
            guard let self = self else { return }
            self.displayedNews = news
            self.tableView.reloadData()
            self.updateEmptyState(show: news.isEmpty)
        }
    }
    
    private func updateEmptyState(show: Bool) {
        emptyStateView.isHidden = !show
        tableView.isHidden = show
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

extension ReadingListViewController: UITableViewDataSource {
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
            // Remove from view model - this will trigger loadReadingList() which updates displayedNews via callback
            self.viewModel.removeFromReadingList(news)
        }
        
        return cell
    }
}

extension ReadingListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let news = displayedNews[indexPath.row]
        let detailViewModel = NewsDetailViewModel(news: news)
        let detailVC = NewsDetailViewController(viewModel: detailViewModel)
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}


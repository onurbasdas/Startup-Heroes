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
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupViewModelBindings() {
        viewModel.onReadingListUpdated = { [weak self] news in
            guard let self = self else { return }
            self.displayedNews = news
            self.tableView.reloadData()
        }
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
            
            if let indexPath = self.tableView.indexPath(for: cell) {
                self.viewModel.removeFromReadingList(news)
                self.displayedNews.remove(at: indexPath.row)
                
                UIView.performWithoutAnimation {
                    self.tableView.deleteRows(at: [indexPath], with: .none)
                }
            }
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


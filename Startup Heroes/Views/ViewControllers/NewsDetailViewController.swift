//
//  NewsDetailViewController.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit
import SnapKit

/// Haber detay view controller
class NewsDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = ColorManager.backgroundSecondary
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
    private let creatorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private let pubDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
    // MARK: - Properties
    private let viewModel: NewsDetailViewModel
    
    // MARK: - Initialization
    init(viewModel: NewsDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = ColorManager.backgroundLight
        
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.alignment = .fill
        
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalToSuperview().offset(-32)
        }
        
        contentView.addArrangedSubview(newsImageView)
        contentView.addArrangedSubview(titleLabel)
        contentView.addArrangedSubview(creatorLabel)
        contentView.addArrangedSubview(pubDateLabel)
        contentView.addArrangedSubview(descriptionLabel)
        contentView.addArrangedSubview(summaryLabel)
        
        newsImageView.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
    }
    
    private func configureContent() {
        titleLabel.text = viewModel.title
        creatorLabel.text = "Yazar: \(viewModel.creator)"
        pubDateLabel.text = "Tarih: \(viewModel.pubDate)"
        descriptionLabel.text = viewModel.description
        summaryLabel.text = viewModel.content
        
        if let imageUrl = viewModel.imageUrl {
            loadImage(from: imageUrl)
        }
    }
    
    // MARK: - Private Methods
    private func loadImage(from url: URL) {
        newsImageView.loadImage(from: url.absoluteString)
    }
}

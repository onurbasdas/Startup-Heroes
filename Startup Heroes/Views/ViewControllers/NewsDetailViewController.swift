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
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let creatorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let pubDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let news: News
    
    // MARK: - Initialization
    init(news: News) {
        self.news = news
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
        view.backgroundColor = .systemBackground
        
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
        
        // UIStackView içine elemanları ekle
        contentView.addArrangedSubview(newsImageView)
        contentView.addArrangedSubview(titleLabel)
        contentView.addArrangedSubview(creatorLabel)
        contentView.addArrangedSubview(pubDateLabel)
        contentView.addArrangedSubview(descriptionLabel)
        contentView.addArrangedSubview(summaryLabel)
        
        // Görsel yüksekliği
        newsImageView.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
    }
    
    private func configureContent() {
        titleLabel.text = news.title
        creatorLabel.text = "Yazar: \(news.creator?.joined(separator: ", ") ?? "Bilinmiyor")"
        pubDateLabel.text = "Tarih: \(news.pubDate?.formattedDate() ?? news.pubDate ?? "Bilinmiyor")"
        descriptionLabel.text = news.description
        summaryLabel.text = news.content ?? news.description
        
        if let imageUrlString = news.imageUrl, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl)
        }
    }
    
    // MARK: - Private Methods
    private func loadImage(from url: URL) {
        newsImageView.loadImage(from: url.absoluteString)
    }
}

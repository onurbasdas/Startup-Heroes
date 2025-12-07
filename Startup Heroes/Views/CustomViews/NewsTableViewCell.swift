//
//  NewsTableViewCell.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit
import SnapKit

/// Haber listesi için özel table view cell
class NewsTableViewCell: UITableViewCell {
    
    static let identifier = "NewsTableViewCell"
    
    // MARK: - UI Components
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()
    
    private let creatorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let pubDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let addToReadingListButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to my reading list", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    // MARK: - Properties
    var onReadingListButtonTapped: ((News) -> Void)?
    private var currentNews: News?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(newsImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(creatorLabel)
        contentView.addSubview(pubDateLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(addToReadingListButton)
        
        newsImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(newsImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
        }
        
        creatorLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        pubDateLabel.snp.makeConstraints { make in
            make.leading.equalTo(creatorLabel.snp.trailing).offset(8)
            make.top.equalTo(creatorLabel)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.top.equalTo(creatorLabel.snp.bottom).offset(4)
        }
        
        addToReadingListButton.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(4)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
        
        addToReadingListButton.addTarget(self, action: #selector(readingListButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    func configure(with news: News, isInReadingList: Bool) {
        currentNews = news
        
        titleLabel.text = news.title
        creatorLabel.text = news.creator?.joined(separator: ", ") ?? "Unknown"
        pubDateLabel.text = news.pubDate?.formattedDate() ?? news.pubDate
        descriptionLabel.text = news.description
        
        // Reading list buton durumunu güncelle
        if isInReadingList {
            addToReadingListButton.setTitle("Remove from my reading list", for: .normal)
        } else {
            addToReadingListButton.setTitle("Add to my reading list", for: .normal)
        }
        
        // Görsel yükleme (şimdilik placeholder)
        if let imageUrlString = news.imageUrl, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl)
        } else {
            newsImageView.image = nil
        }
    }
    
    // MARK: - Private Methods
    private func loadImage(from url: URL) {
        newsImageView.loadImage(from: url.absoluteString)
    }
    
    @objc private func readingListButtonTapped() {
        guard let news = currentNews else { return }
        onReadingListButtonTapped?(news)
    }
}

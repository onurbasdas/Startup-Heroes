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
    
    private let shimmerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()
    
    private let shimmerGradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemGray4.cgColor,
            UIColor.systemGray5.cgColor,
            UIColor.systemGray4.cgColor
        ]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.numberOfLines = 3
        label.textColor = .label
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let creatorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let pubDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
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
        button.contentHorizontalAlignment = .leading
        return button
    }()
    
    // MARK: - Properties
    var onReadingListButtonTapped: ((News) -> Void)?
    private var currentNews: News?
    private var currentImageURL: URL?
    
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
        newsImageView.addSubview(shimmerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(creatorLabel)
        contentView.addSubview(pubDateLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(addToReadingListButton)
        
        newsImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        shimmerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(newsImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
        }
        
        creatorLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        pubDateLabel.snp.makeConstraints { make in
            make.leading.equalTo(creatorLabel.snp.trailing).offset(8)
            make.top.equalTo(creatorLabel)
            make.trailing.lessThanOrEqualTo(titleLabel)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.top.equalTo(creatorLabel.snp.bottom).offset(10)
        }
        
        addToReadingListButton.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        addToReadingListButton.addTarget(self, action: #selector(readingListButtonTapped), for: .touchUpInside)
        
        shimmerView.layer.addSublayer(shimmerGradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerGradientLayer.frame = shimmerView.bounds
    }
    
    // MARK: - Configuration
    func configure(with news: News, isInReadingList: Bool) {
        currentNews = news
        
        titleLabel.text = news.title
        creatorLabel.text = news.creator?.joined(separator: ", ") ?? "Unknown"
        pubDateLabel.text = news.pubDate?.formattedDate() ?? news.pubDate
        descriptionLabel.text = news.description
        
        if isInReadingList {
            addToReadingListButton.setTitle("Remove from my reading list", for: .normal)
        } else {
            addToReadingListButton.setTitle("Add to my reading list", for: .normal)
        }
        
        newsImageView.image = nil
        startShimmer()
        
        if let imageUrlString = news.imageUrl, let imageUrl = URL(string: imageUrlString) {
            currentImageURL = imageUrl
            loadImage(from: imageUrl)
        } else {
            stopShimmer()
            currentImageURL = nil
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImageView.image = nil
        stopShimmer()
        if let url = currentImageURL {
            ImageLoader.shared.cancelLoad(for: url)
        }
        currentImageURL = nil
    }
    
    // MARK: - Private Methods
    private func loadImage(from url: URL) {
        ImageLoader.shared.loadImage(from: url) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.stopShimmer()
                switch result {
                case .success(let image):
                    UIView.transition(with: self.newsImageView, duration: 0.3, options: .transitionCrossDissolve) {
                        self.newsImageView.image = image
                    }
                case .failure(let error):
                    debugPrint("DEBUG - Failed to load image from \(url.absoluteString): \(error.localizedDescription)")
                    self.newsImageView.backgroundColor = .systemGray5
                }
            }
        }
    }
    
    private func startShimmer() {
        shimmerView.isHidden = false
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -shimmerView.bounds.width * 2
        animation.toValue = shimmerView.bounds.width * 2
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        shimmerGradientLayer.add(animation, forKey: "shimmer")
    }
    
    private func stopShimmer() {
        shimmerView.isHidden = true
        shimmerGradientLayer.removeAnimation(forKey: "shimmer")
    }
    
    @objc private func readingListButtonTapped() {
        guard let news = currentNews else { return }
        onReadingListButtonTapped?(news)
    }
}

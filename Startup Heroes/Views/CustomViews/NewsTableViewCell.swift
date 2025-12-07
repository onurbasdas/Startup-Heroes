//
//  NewsTableViewCell.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit
import SnapKit

class NewsTableViewCell: UITableViewCell {
    
    static let identifier = "NewsTableViewCell"
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = ColorManager.backgroundSecondary
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let shimmerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.backgroundSecondary
        view.layer.cornerRadius = 12
        view.isHidden = true
        view.clipsToBounds = true
        return view
    }()
    
    private let shimmerGradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = ColorManager.shimmerGradientColors()
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: -1.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.newsTitle
        label.numberOfLines = 3
        label.textColor = ColorManager.textPrimary
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let creatorLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.newsCreator
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private let pubDateLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.newsDate
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.newsDescription
        label.numberOfLines = 2
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private let addToReadingListButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to my reading list", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(ColorManager.primaryOrange, for: .normal)
        button.contentHorizontalAlignment = .leading
        return button
    }()
    
    // MARK: - Properties
    var onReadingListButtonTapped: ((News) -> Void)?
    private var currentNews: News?
    private var currentImageURL: URL?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(newsImageView)
        newsImageView.addSubview(shimmerView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(creatorLabel)
        cardView.addSubview(pubDateLabel)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(addToReadingListButton)
        
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        newsImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.equalTo(110)
            make.height.equalTo(110)
        }
        
        shimmerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        shimmerView.layer.cornerRadius = 12
        shimmerView.layer.masksToBounds = true
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(newsImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
        }
        
        creatorLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
        }
        
        pubDateLabel.snp.makeConstraints { make in
            make.leading.equalTo(creatorLabel.snp.trailing).offset(8)
            make.top.equalTo(creatorLabel)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.top.equalTo(creatorLabel.snp.bottom).offset(10)
        }
        
        addToReadingListButton.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(14)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        addToReadingListButton.addTarget(self, action: #selector(readingListButtonTapped), for: .touchUpInside)
        
        shimmerView.layer.addSublayer(shimmerGradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerGradientLayer.frame = shimmerView.bounds
        
        cardView.layer.shadowPath = UIBezierPath(
            roundedRect: cardView.bounds,
            cornerRadius: cardView.layer.cornerRadius
        ).cgPath
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.2) {
            self.cardView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.cardView.alpha = highlighted ? 0.9 : 1.0
        }
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
                    self.newsImageView.backgroundColor = ColorManager.backgroundSecondary
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
        animation.autoreverses = false
        
        shimmerGradientLayer.removeAnimation(forKey: "shimmer")
        shimmerGradientLayer.add(animation, forKey: "shimmer")
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.3
        opacityAnimation.toValue = 0.8
        opacityAnimation.duration = 1.5
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.autoreverses = true
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        shimmerGradientLayer.removeAnimation(forKey: "shimmerOpacity")
        shimmerGradientLayer.add(opacityAnimation, forKey: "shimmerOpacity")
    }
    
    private func stopShimmer() {
        shimmerView.isHidden = true
        shimmerGradientLayer.removeAnimation(forKey: "shimmer")
        shimmerGradientLayer.removeAnimation(forKey: "shimmerOpacity")
    }
    
    @objc private func readingListButtonTapped() {
        guard let news = currentNews else { return }
        onReadingListButtonTapped?(news)
    }
}

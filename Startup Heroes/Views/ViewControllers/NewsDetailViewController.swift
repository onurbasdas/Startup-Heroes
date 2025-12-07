//
//  NewsDetailViewController.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit
import SnapKit

class NewsDetailViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    
    private let imageCardView: UIView = {
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
        imageView.layer.cornerRadius = 16
        return imageView
    }()
    
    private let titleCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 26)
        label.numberOfLines = 0
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
    private let infoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let creatorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private let pubDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private let descriptionCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
    private let contentCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
    private let viewModel: NewsDetailViewModel
    
    init(viewModel: NewsDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
    }
    
    private func setupUI() {
        view.backgroundColor = ColorManager.backgroundLight
        
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        contentView.axis = .vertical
        contentView.spacing = 20
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
        
        setupImageCard()
        setupTitleCard()
        setupInfoCard()
        setupDescriptionCard()
        setupContentCard()
    }
    
    private func setupImageCard() {
        imageCardView.addSubview(newsImageView)
        contentView.addArrangedSubview(imageCardView)
        
        newsImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(280)
        }
    }
    
    private func setupTitleCard() {
        titleCardView.addSubview(titleLabel)
        contentView.addArrangedSubview(titleCardView)
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    private func setupInfoCard() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        
        stackView.addArrangedSubview(creatorLabel)
        stackView.addArrangedSubview(pubDateLabel)
        
        infoCardView.addSubview(stackView)
        contentView.addArrangedSubview(infoCardView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    private func setupDescriptionCard() {
        descriptionCardView.addSubview(descriptionLabel)
        contentView.addArrangedSubview(descriptionCardView)
        
        descriptionLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    private func setupContentCard() {
        contentCardView.addSubview(summaryLabel)
        contentView.addArrangedSubview(contentCardView)
        
        summaryLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    private func configureContent() {
        titleLabel.text = viewModel.title
        
        let creatorText = NSMutableAttributedString(
            string: "Yazar: ",
            attributes: [.foregroundColor: ColorManager.textSecondary, .font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        )
        creatorText.append(NSAttributedString(
            string: viewModel.creator,
            attributes: [.foregroundColor: ColorManager.primaryOrange, .font: UIFont.systemFont(ofSize: 16, weight: .semibold)]
        ))
        creatorLabel.attributedText = creatorText
        
        let dateText = NSMutableAttributedString(
            string: "Tarih: ",
            attributes: [.foregroundColor: ColorManager.textSecondary, .font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        )
        dateText.append(NSAttributedString(
            string: viewModel.pubDate,
            attributes: [.foregroundColor: ColorManager.textPrimary, .font: UIFont.systemFont(ofSize: 16, weight: .regular)]
        ))
        pubDateLabel.attributedText = dateText
        
        if let description = viewModel.description {
            descriptionLabel.attributedText = NSAttributedString(
                string: description,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 17),
                    .foregroundColor: ColorManager.textPrimary,
                    .paragraphStyle: {
                        let style = NSMutableParagraphStyle()
                        style.lineSpacing = 6
                        return style
                    }()
                ]
            )
        }
        
        if let content = viewModel.content {
            summaryLabel.attributedText = NSAttributedString(
                string: content,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 17),
                    .foregroundColor: ColorManager.textPrimary,
                    .paragraphStyle: {
                        let style = NSMutableParagraphStyle()
                        style.lineSpacing = 6
                        return style
                    }()
                ]
            )
        }
        
        if let imageUrl = viewModel.imageUrl {
            loadImage(from: imageUrl)
        }
    }
    
    private func loadImage(from url: URL) {
        newsImageView.loadImage(from: url.absoluteString)
    }
}

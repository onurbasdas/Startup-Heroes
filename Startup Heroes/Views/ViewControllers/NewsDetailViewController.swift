//
//  NewsDetailViewController.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit
import SnapKit

class NewsDetailViewController: BaseViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    
    private let imageCardView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.cardBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = ColorManager.shadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 1.0
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
        view.backgroundColor = ColorManager.cardBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = ColorManager.shadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 1.0
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.detailTitle
        label.numberOfLines = 0
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
    private let infoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.cardBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = ColorManager.shadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 1.0
        return view
    }()
    
    private let creatorLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.detailInfo
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private let pubDateLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.detailInfo
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private let descriptionCardView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.cardBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = ColorManager.shadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 1.0
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.detailBody
        label.numberOfLines = 0
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
    private let contentCardView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.cardBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = ColorManager.shadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 1.0
        return view
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.detailBody
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
        
        setupNavigationBar()
        setupUI()
        configureContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
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
        titleCardView.isHidden = viewModel.title == nil || viewModel.title?.isEmpty == true
        titleLabel.text = viewModel.title
        
        let creatorText = NSMutableAttributedString(
            string: "Yazar: ",
            attributes: [.foregroundColor: ColorManager.textSecondary, .font: FontManager.detailInfo]
        )
        creatorText.append(NSAttributedString(
            string: viewModel.creator,
            attributes: [.foregroundColor: ColorManager.primaryOrange, .font: FontManager.titleFont(size: 16)]
        ))
        creatorLabel.attributedText = creatorText
        
        let dateText = NSMutableAttributedString(
            string: "Tarih: ",
            attributes: [.foregroundColor: ColorManager.textSecondary, .font: FontManager.detailInfo]
        )
        dateText.append(NSAttributedString(
            string: viewModel.pubDate,
            attributes: [.foregroundColor: ColorManager.textPrimary, .font: FontManager.detailBody]
        ))
        pubDateLabel.attributedText = dateText
        
        if let description = viewModel.description, !description.isEmpty {
            descriptionCardView.isHidden = false
            descriptionLabel.attributedText = NSAttributedString(
                string: description,
                attributes: [
                    .font: FontManager.detailBody,
                    .foregroundColor: ColorManager.textPrimary,
                    .paragraphStyle: {
                        let style = NSMutableParagraphStyle()
                        style.lineSpacing = 6
                        return style
                    }()
                ]
            )
        } else {
            descriptionCardView.isHidden = true
        }
        
        if let content = viewModel.content, !content.isEmpty {
            contentCardView.isHidden = false
            summaryLabel.attributedText = NSAttributedString(
                string: content,
                attributes: [
                    .font: FontManager.detailBody,
                    .foregroundColor: ColorManager.textPrimary,
                    .paragraphStyle: {
                        let style = NSMutableParagraphStyle()
                        style.lineSpacing = 6
                        return style
                    }()
                ]
            )
        } else {
            contentCardView.isHidden = true
        }
        
        if let imageUrl = viewModel.imageUrl {
            imageCardView.isHidden = false
            loadImage(from: imageUrl)
        } else {
            imageCardView.isHidden = true
        }
    }
    
    private func loadImage(from url: URL) {
        newsImageView.loadImage(from: url.absoluteString) { [weak self] success in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.imageCardView.isHidden = !success
            }
        }
    }
}

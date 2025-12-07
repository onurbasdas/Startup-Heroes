//
//  LaunchScreenViewController.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit
import SnapKit

class LaunchScreenViewController: UIViewController {
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = ColorManager.orangeGradientColors()
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradient
    }()
    
    private let cardView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1.0, green: 0.65, blue: 0.3, alpha: 0.3)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let cardView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1.0, green: 0.65, blue: 0.3, alpha: 0.25)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let newsIconView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let newsLabel: UILabel = {
        let label = UILabel()
        label.text = "NEWS"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = ColorManager.primaryOrange
        label.textAlignment = .center
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ColorManager.primaryOrange
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "STARTUP HEROES"
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = containerView.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = ColorManager.backgroundLight
        
        view.addSubview(containerView)
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        
        containerView.addSubview(cardView1)
        containerView.addSubview(cardView2)
        containerView.addSubview(newsIconView)
        newsIconView.addSubview(newsLabel)
        newsIconView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(280)
        }
        
        cardView1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(60)
        }
        
        cardView2.snp.makeConstraints { make in
            make.top.equalTo(cardView1.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        newsIconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(100)
        }
        
        newsLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(newsLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(newsIconView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        
        createNewsIcon()
    }
    
    private func createNewsIcon() {
        let iconSize = CGSize(width: 80, height: 50)
        let renderer = UIGraphicsImageRenderer(size: iconSize)
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            
            cgContext.setFillColor(ColorManager.primaryOrange.cgColor)
            
            let mountainPath = UIBezierPath()
            mountainPath.move(to: CGPoint(x: 20, y: 35))
            mountainPath.addLine(to: CGPoint(x: 15, y: 25))
            mountainPath.addLine(to: CGPoint(x: 10, y: 35))
            mountainPath.close()
            mountainPath.fill()
            
            let mountainPath2 = UIBezierPath()
            mountainPath2.move(to: CGPoint(x: 30, y: 35))
            mountainPath2.addLine(to: CGPoint(x: 25, y: 20))
            mountainPath2.addLine(to: CGPoint(x: 20, y: 35))
            mountainPath2.close()
            mountainPath2.fill()
            
            cgContext.setFillColor(ColorManager.primaryOrange.cgColor)
            cgContext.fillEllipse(in: CGRect(x: 12, y: 15, width: 6, height: 6))
            
            cgContext.setFillColor(ColorManager.primaryOrange.cgColor)
            for i in 0..<3 {
                let rect = CGRect(x: 45 + i * 8, y: 25 + i * 5, width: 20, height: 2)
                cgContext.fill(rect)
            }
        }
        
        iconImageView.image = image
    }
    
    func animateLaunch(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
            self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.containerView.alpha = 0.9
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut) {
                self.view.alpha = 0
            } completion: { _ in
                completion()
            }
        }
    }
}


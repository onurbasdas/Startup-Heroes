//
//  BaseViewController.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {
    
    private let loadingOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.isHidden = true
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = ColorManager.primaryOrange
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingOverlay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLoadingOverlay()
    }
    
    private func setupLoadingOverlay() {
        guard loadingOverlayView.superview == nil else { return }
        
        if let windowScene = view.window?.windowScene,
           let window = windowScene.windows.first {
            window.addSubview(loadingOverlayView)
            loadingOverlayView.addSubview(loadingIndicator)
            
            loadingOverlayView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            loadingIndicator.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
    }
    
    func showLoading() {
        loadingOverlayView.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        loadingOverlayView.isHidden = true
        loadingIndicator.stopAnimating()
    }
}


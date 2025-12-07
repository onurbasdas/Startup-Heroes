//
//  BaseViewModel.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation

class BaseViewModel {
    var onLoadingChanged: ((Bool) -> Void)?
    
    private var isLoading: Bool = false {
        didSet {
            onLoadingChanged?(isLoading)
        }
    }
    
    @MainActor
    func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    deinit {
    }
}


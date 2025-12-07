//
//  NetworkMonitor.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation
import Network

/// Network Monitor protokolü - Test edilebilirlik için
protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
    func startMonitoring()
    func stopMonitoring()
    func onConnectionChange(_ handler: @escaping (Bool) -> Void)
}

/// Network bağlantı izleyicisi - İnternet durumunu kontrol eder
class NetworkMonitor: NetworkMonitorProtocol {
    
    // MARK: - Properties
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var connectionChangeHandler: ((Bool) -> Void)?
    
    var isConnected: Bool {
        return monitor.currentPath.status == .satisfied
    }
    
    // MARK: - Initialization
    init() {
        startMonitoring()
    }
    
    // MARK: - Public Methods
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let isConnected = path.status == .satisfied
            debugPrint("DEBUG - Network status changed: \(isConnected ? "Connected" : "Disconnected")")
            DispatchQueue.main.async {
                self.connectionChangeHandler?(isConnected)
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    func onConnectionChange(_ handler: @escaping (Bool) -> Void) {
        self.connectionChangeHandler = handler
    }
}

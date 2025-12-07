//
//  NetworkMonitor.swift
//  Startup Heroes
//
//  Created by Onur Basdas on 7.12.2025.
//

import Foundation
import Network

protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
    func startMonitoring()
    func stopMonitoring()
    func onConnectionChange(_ handler: @escaping (Bool) -> Void)
}

class NetworkMonitor: NetworkMonitorProtocol {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var connectionChangeHandler: ((Bool) -> Void)?
    
    var isConnected: Bool {
        return monitor.currentPath.status == .satisfied
    }
    
    init() {
        startMonitoring()
    }
    
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

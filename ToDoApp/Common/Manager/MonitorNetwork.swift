//
//  MonitorNetwork.swift
//  PlantIdentification
//
//  Created by Manh Nguyen Ngoc on 08/10/2021.
//

import UIKit
import Network

class MonitorNetwork {
    static let shared = MonitorNetwork()
    
    private var turnOnNetwork = false
    
    func isConnectedNetwork() -> Bool {
        return turnOnNetwork
    }
    
    func configMonitorNetwork() {
        let monitorNetwork = NWPathMonitor()
        monitorNetwork.pathUpdateHandler = { path in
            
            if path.status == .satisfied {
                self.turnOnNetwork = true
            } else {
                self.turnOnNetwork = false
            }
            
            NotificationCenter.default.post(name: Notification.Name.didChangeConnectNetworkActivity, object: nil)
        }
        
        monitorNetwork.start(queue: .main)
    }
}

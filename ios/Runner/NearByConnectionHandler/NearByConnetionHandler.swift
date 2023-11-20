//
//  FlutterNearByController.swift
//  Runner
//
//  Created by ahhyun lee on 11/16/23.
//

import NearbyConnections
import Foundation
import UIKit
import Flutter

class NearByConnectionHandler{
    var endpointName = Constants.defaultEndpointName
    var strategy = Strategy.pointToPoint
    
    var requests: [ConnectionRequest] = []
    var connections: [ConnectedEndpoint] = []
    var endpoints: [DiscoveredEndpoint] = []
    
    var connectionManager: ConnectionManager!
    var advertiser: Advertiser?
    var discoverer: Discoverer?
    
    private var isDiscovering =  Constants.defaultDiscoveryState
    
    init() {
        self.connectionManager = ConnectionManager(serviceID: Constants.serviceId, strategy: strategy)
        advertiser?.delegate = self
        discoverer?.delegate = self
    }
    
    func invalidateDiscovery(isDiscoveryEnabled:Bool) {
        defer {
            isDiscovering = isDiscoveryEnabled
        }
        if isDiscovering {
            discoverer?.stopDiscovery()
        }
        if !isDiscoveryEnabled {
            return
        }
        
        connectionManager.delegate = self
        
        discoverer = Discoverer(connectionManager: connectionManager)
        discoverer?.delegate = self
        discoverer?.startDiscovery()
        print("invalidateDiscovery => 결과")
    }
    
    func requestConnection(to endpointID: EndpointID) {
        discoverer?.requestConnection(to: endpointID, using: endpointName.data(using: .utf8)!)
    }
    
}


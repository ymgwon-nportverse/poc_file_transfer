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
    
    var connectionManager: ConnectionManager
    var advertiser: Advertiser
    var discoverer: Discoverer
    
    private var isDiscovering =  Constants.defaultDiscoveryState
    
    init() {
        connectionManager = ConnectionManager(serviceID: "com.nportverse.poc", strategy:.pointToPoint)
        
        advertiser  = Advertiser(connectionManager: connectionManager)
        discoverer = Discoverer(connectionManager: connectionManager)
        
        advertiser.delegate = self
        discoverer.delegate = self
        connectionManager.delegate = self
    }
    
    func invalidateAdvertising(isEnabled:Bool) {
//        defer {
//            isAdvertising = isEnabled
//        }
//        if isAdvertising {
//            advertiser.stopAdvertising()
//            
//        }
//        if !isEnabled{
//            return
//        }
        
        advertiser.startAdvertising(using: endpointName.data(using: .utf8)!)
    }
    
    func invalidateDiscovery(isDiscoveryEnabled:Bool) {
//        defer {
//            isDiscovering = isEnabled
//        }
//        if isDiscovering {
//            discoverer.stopDiscovery()
//        }
//        if !isEnabled{
//            return
//        }
        discoverer.startDiscovery()
        print("invalidateDiscovery => 결과")
    }
    
    
    func requestConnection(to endpointID: EndpointID) {
        discoverer.requestConnection(to: endpointID, using: endpointName.data(using: .utf8)!)
    }
    
    func disconnect(from endpointID: EndpointID) {
        connectionManager.disconnect(from: endpointID)
    }
    
    func sendBytes(to endpointIDs: [EndpointID]) {
        let payloadID = PayloadID.unique()
        let token = connectionManager.send(Constants.bytePayload.data(using: .utf8)!, to: endpointIDs, id: payloadID)
        let payload = Payload(
            id: payloadID,
            type: .bytes,
            status: .inProgress(Progress()),
            isIncoming: false,
            cancellationToken: token
        )
        for endpointID in endpointIDs {
            guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            connections[index].payloads.insert(payload, at: 0)
        }
    }
}


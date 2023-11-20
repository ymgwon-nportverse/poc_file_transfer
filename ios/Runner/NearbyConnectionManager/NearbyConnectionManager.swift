//
//  NearbyConnectionManager.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections


class NearbyConnectionManager{
    @Published private(set) var endpoints: [DiscoveredEndpoint] = []
    @Published private(set) var requests: [ConnectionRequest] = []
    @Published private(set) var connections: [ConnectedEndpoint] = []
    
    @Published var endpointName = Constants.defaultEndpointName {
        didSet {
            invalidateAdvertising()
        }
    }
    @Published var strategy = Constants.defaultStrategy { // STAR
        didSet {
           invalidateAdvertising()
            invalidateDiscovery()
        }
    }
    @Published var isAdvertisingEnabled = Constants.defaultAdvertisingState { // 송신 상태 on
        didSet {
          invalidateAdvertising()
        }
    }
    @Published var isDiscoveryEnabled = Constants.defaultDiscoveryState { // 수신 상태 on
        didSet {
        invalidateDiscovery()
        }
    }


    var connectionManager: ConnectionManager  = ConnectionManager(serviceID: Constants.serviceId, strategy: Strategy.star)
    var advertiser: Advertiser?
    var discoverer: Discoverer?

    init() {
       invalidateAdvertising()
        invalidateDiscovery()
    }

    private var isAdvertising = Constants.defaultAdvertisingState
    
    private func invalidateAdvertising() {
        
        defer {
            isAdvertising = isAdvertisingEnabled
        }
        if isAdvertising {
            advertiser?.stopAdvertising()
        }
        if !isAdvertisingEnabled {
            return
        }
        connectionManager.delegate = self
        advertiser = Advertiser(connectionManager: connectionManager)
        advertiser?.delegate = self
        advertiser?.startAdvertising(using: endpointName.data(using: .utf8)!)
    }

    private var isDiscovering = Constants.defaultDiscoveryState
    private func invalidateDiscovery() {
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
    }

    func requestConnection(to endpointID: EndpointID) {
        discoverer?.requestConnection(to: endpointID, using: endpointName.data(using: .utf8)!)
    }

    func disconnect(from endpointID: EndpointID) {
        connectionManager.disconnect(from: endpointID)
    }

    func sendBytes(to endpointIDs: [EndpointID]) {
        let payloadID = PayloadID.unique()
        let token = connectionManager.send(Constants.bytePayload.data(using: .utf8)!, to: endpointIDs, id: payloadID)
        let payload = Payload(
            id: payloadID,
            type: .bytes
          //  status: .inProgress(Progress()),
         //   isIncoming: false,
       //     cancellationToken: token
        )
        for endpointID in endpointIDs {
            guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            connections[index].payloads.insert(payload, at: 0)
        }
    }
}

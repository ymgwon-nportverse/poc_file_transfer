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

class NearByConnectionController{
    static let shared = NearByConnectionController()
    
    var endpointName = Constants.defaultEndpointName
    var strategy = Strategy.pointToPoint
    
    var requests: [ConnectionRequest] = []
    var connections: [ConnectedEndpoint] = []
    var endpoints: [DiscoveredEndpoint] = []
    
    var connectionManager: ConnectionManager
    var advertiser: Advertiser
    var discoverer: Discoverer
    
    var nearbyConnectionsInvokeEvent: NearbyConnectionsInvokeEvent = NearbyConnectionsInvokeEvent()
    
    private init() {
        connectionManager = ConnectionManager(serviceID: Constants.serviceId, strategy:.pointToPoint)
        
        advertiser  = Advertiser(connectionManager: connectionManager)
        discoverer = Discoverer(connectionManager: connectionManager)
        
        advertiser.delegate = self
        discoverer.delegate = self
        connectionManager.delegate = self
    }
    
    func invalidateAdvertising(isEnabled:Bool) {
        if !isEnabled{
            advertiser.stopAdvertising()
        }else{
            advertiser.startAdvertising(using: endpointName.data(using: .utf8)!)
        }
        
        advertiser.startAdvertising(using: endpointName.data(using: .utf8)!)
    }
    
    func invalidateDiscovery(isEnabled:Bool) {
        if !isEnabled{
            discoverer.stopDiscovery()
        }else{
            discoverer.startDiscovery()
        }
    }
    
    
    func requestConnection(to endpointID: EndpointID) {
        discoverer.requestConnection(to: endpointID, using:endpointName.data(using: .utf8)!)
    }
    
    func disconnect(from endpointID: EndpointID) {
        connectionManager.disconnect(from: endpointID)
    }
    
    func rejection(){}
    
    func sendPayload (to endpointIDs: [EndpointID],bytes:FlutterStandardTypedData){
        let payloadID = PayloadID.unique()
        let token = connectionManager.send(Data(bytes.data), to: endpointIDs, id: payloadID)
        let payload = Payload(
            id: payloadID,
            type: .bytes,
            payloadStatus: .inProgress, // 여기 todo
            isIncoming: false,
            cancellationToken: token
        )
        
        for endpointID in endpointIDs {
            guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            connections[index].payloads.insert(payload, at: 0)
        }
           for endpointID in endpointIDs {
                    if(connections.isEmpty){
                        var payloads =  connections.first?.payloads
                        payloads?.append(payload)
                    }
                }
        
    }
    
    func acceptEndPoint(endpointID:String){
        let connectionRequest = requests.first { $0.endpointID == endpointID }
        connectionRequest?.shouldAccept(true)
    }
    
    func stopAllEndpoints(){
        endpoints.removeAll()
    }
    
    func stopAllactions(){
        endpoints.removeAll()
        requests.removeAll()
        connections.removeAll()
    }
    
    
    func cancelPayload(to endpointIDs: [EndpointID],bytes:FlutterStandardTypedData){
        let payloadID = PayloadID.unique()
        let token = connectionManager.send(Constants.bytePayload.data(using: .utf8)!, to: endpointIDs, id: payloadID)
        let payload = Payload(
            id: payloadID,
            type: .bytes,
            payloadStatus: .inProgress,
            isIncoming: false,
            cancellationToken: token
        )
        for endpointID in endpointIDs {
            guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            connections[index].payloads.remove(at: 0)
        }
    }
    
    
}

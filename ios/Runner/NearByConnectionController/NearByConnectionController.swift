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
import OSLog

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
        
        os_log("[NearByConnectionController]__init")
    }
    
    func invalidateAdvertising(isEnabled:Bool) {
        if !isEnabled{
            advertiser.stopAdvertising()
        }else{
            advertiser.startAdvertising(using: endpointName.data(using: .utf8)!)
        }
        os_log("[NearByConnectionController]__invalidateAdvertising value :\(isEnabled)")
    }
    
    func invalidateDiscovery(isEnabled:Bool) {
        if !isEnabled{
            discoverer.stopDiscovery()
        }else{
            discoverer.startDiscovery()
        }
        os_log("[NearByConnectionController]__invalidateDiscovery value : \(isEnabled)")
    }
    
    
    func requestConnection(to endpointID: EndpointID) {
        discoverer.requestConnection(to: endpointID, using:endpointName.data(using: .utf8)!)
        os_log("[NearByConnectionController]__requestConnection")
    }
    
    func disconnect(from endpointID: EndpointID) {
        connectionManager.disconnect(from: endpointID)
        os_log("[NearByConnectionController]__disconnect")
    }
    
    func rejection(){
        os_log("[NearByConnectionController]__rejection")
    }
    
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
        
//        for endpointID in endpointIDs {
//            guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
//                return
//            }
//            connections[index].payloads.insert(payload, at: 0)
//        }
           for endpointID in endpointIDs {
                    if(connections.isEmpty){
                        var payloads =  connections.first?.payloads
                        payloads?.append(payload)
                    }
                }
        os_log("[NearByConnectionController]__sendPayload")
    }
    
    func acceptEndPoint(endpointID:String){
        let connectionRequest = requests.first { $0.endpointID == endpointID }
        connectionRequest?.shouldAccept(true)
        os_log("[NearByConnectionController]__acceptEndPoint")
    }
    
    func stopAllEndpoints(){
        endpoints.removeAll()
        os_log("[NearByConnectionController]__stopAllEndpoints")
    }
    
    // todo 사용중인지 확인
    func stopAllactions(){
        endpoints.removeAll()
        requests.removeAll()
        connections.removeAll()
        os_log("[NearByConnectionController]__stopAllactions")
    }
    
    
    func cancelPayload(to endpointIDs: [EndpointID],bytes:FlutterStandardTypedData){
        let payloadID = PayloadID.unique()
        let token = connectionManager.send(Data(bytes.data), to: endpointIDs, id: payloadID)
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
        os_log("[NearByConnectionController]__cancelPayload")
    }
    
    
}

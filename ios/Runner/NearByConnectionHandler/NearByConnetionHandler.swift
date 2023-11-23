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
    
    func acceptEndPoint(ep:String){
        let connectionRequest = requests.first { $0.endpointID == ep }
      //  connectionRequest.
       //todo  onPayloadReceived,
        connectionRequest?.shouldAccept(true)
        
    }
    
    func onPayloadReceived(){
        //_ endpointId:String, payload:Payload
        
        
    }
    
    func stopAllEndpoints(){
        requests.removeAll()
        connections.removeAll()
        endpoints.removeAll()
    }
    

    
    func  rejectConnection(){
     //   advertiser.connection?.rejectedConnection(toEndpoint: <#T##String#>, with: <#T##GNCStatus#>)
    }
    
    func cancelPayload(to endpointIDs: [EndpointID]){
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
            connections[index].payloads.remove(at: 0)
        }
    }
}


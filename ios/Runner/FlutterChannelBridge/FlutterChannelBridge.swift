//
//  FlutterNearByController.swift
//  Runner
//
//  Created by ahhyun lee on 11/16/23.
//

import Foundation


struct FlutterChannelBridge: FlutterNearByDelegate{
    func startDiscovery(userName: String, strategy: String, serviceId: String, onEndpointFound: () -> (), onEndpointLost: () -> ()) {
      
    }
    
    func startAdvertising(userName: String, strategy: String, serviceId: String, onBandwidthChanged: () -> (), onConnectionInitiated: () -> (), onConnectionResult: () -> (), onDisconnected: () -> ()) {
        
    }
    
    func stopDiscovery() {
        
    }
    
    func stopAdvertising() {
        
    }
    
    func stopAllEndpoints() {
        
    }
    
    func disconnectFromEndpoint(endpointId: String) {
        
    }
    
    func acceptConnection(endpointId: String, onPayloadReceived: () -> (), onPayloadTransferUpdate: () -> ()) {
        
    }
    
    func requestConnection(userName: String, endpointId: String, onBandwidthChanged: () -> (), onConnectionInitiated: () -> (), onConnectionResult: () -> (), onDisconnected: () -> ()) {
        
    }
    
    func rejectConnection(endpointId: String) {
        
    }
    
    func sendPayload(endpointId: String, paylodad: Payload) {
        
    }
    
    func cancelPayload(payloadId: String) {
        
    }
    
    func onConnectionInitiated(endpointId: String, connectionInfo: ConnectionInfo) {
        
    }
    
    func onBandwidthChanged(endpointId: String, quality: BandwidthQuality) {
        
    }
    
    func onConnectionResult(endpointId: String, status: ConnectionStatus) {
        
    }
    
    func onDisconnected(endpointId: String) {
        
    }
    
    func onPayloadReceived(endpointId: String, payload: Payload) {
        
    }
    
    func onEndpointFound(endpointId: String, endpointName: String, serviceId: String) {
        
    }
    
    func onEndpointLost(endpointId: String?) {
        
    }
    
    func onPayloadTransferUpdate(endpointId: String, payloadTransferUpdate: PayloadTransferUpdate) {
        
    }
    

    
}

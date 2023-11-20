//
//  Enum.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections

enum PayloadType {
    case none,bytes, stream, file
}

enum ConnectionStatus {
    case  connected,
          rejected,
          error
}

enum PayloadStatus {
    case inProgress(Progress), success, failure, canceled
}

enum BandwidthQuality {
    case  unknown,  low,  medium,  high
}

enum FlutterInvokeMethodEvent {
    case onAdvertiseConnectionInitiated,
         onAdvertiseConnectionResult,
         onAdvertiseDisconnected,
         
         onDiscoveryConnectionInitiated,
         onDiscoveryConnectionResult,
         onDiscoveryDisconnected,
         
         onEndpointFound,
         onEndpointLost,
         
         onPayloadReceived,
         onPayloadTransferUpdate
}

extension FlutterInvokeMethodEvent{
    var eventName:String {
        switch self{
            
        case .onAdvertiseConnectionInitiated : return "onAdvertiseConnectionInitiated"
        case .onAdvertiseConnectionResult : return "onAdvertiseConnectionResult"
        case .onAdvertiseDisconnected: return "onAdvertiseDisconnected"
            
        case .onDiscoveryConnectionInitiated :return "onDiscoveryConnectionInitiated"
        case .onDiscoveryConnectionResult :return "onDiscoveryConnectionResult"
        case .onDiscoveryDisconnected: return "onDiscoveryDisconnected"
            
        case .onEndpointFound :return "onEndpointFound"
        case .onEndpointLost :return "onEndpointLost"
            
        case .onPayloadReceived: return "onPayloadReceived"
        case .onPayloadTransferUpdate :return "onPayloadTransferUpdate"
        }
    }
}


enum FlutterNearbyMethodCallName : String {
    case startAdvertising = "startAdvertising"
    case stopAdvertising = "stopAdvertising"
    
    case startDiscovery = "startDiscovery"
    case stopDiscovery = "stopDiscovery"
    
    case stopAllEndpoints = "stopAllEndpoints"
    case disconnectFromEndpoint = "disconnectFromEndpoint"
    
    case acceptConnection = "acceptConnection"
    case requestConnection = "requestConnection"
    case rejectConnection = "rejectConnection"
    
    case sendPayload = "sendPayload"
    case cancelPayload = "cancelPayload" 
}


extension FlutterNearbyMethodCallName{
    var methodCall: FlutterNearbyMethodCallDelegate {
        switch self{
        case .startDiscovery: return StartDiscovery()
        case .startAdvertising: return StartAdvertising()
        case .stopDiscovery: return StopDiscovery()
        case .stopAdvertising: return StopAdvertising()
        case .stopAllEndpoints: return StopAllEndpoints()
        case .disconnectFromEndpoint: return DisconnectFromEndpoint()
        case .acceptConnection: return AcceptConnection()
        case .requestConnection: return RequestConnection()
        case .rejectConnection: return RejectConnection()
        case .sendPayload: return SendPayload()
        case .cancelPayload: return  CancelPayload()
        }
    }
}

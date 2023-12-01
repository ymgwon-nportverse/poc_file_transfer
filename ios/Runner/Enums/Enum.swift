//
//  Enum.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections

enum ConnectionStatus : String {
    case  connected = "connected"
    case  rejected = "rejected"
    case  error = "error"
}

enum FlutterInvokeMethodEvent {
    case onConnectionInitiated,
         onConnectionResult,
         onDisconnected,
         onEndpointFound,
         onEndpointLost,
         onPayloadReceived,
         onPayloadTransferUpdate
}

extension FlutterInvokeMethodEvent{
    var toString:String {
        switch self{
        case .onConnectionInitiated  :return Constants.onConnectionInitiated
        case .onConnectionResult :return Constants.onConnectionResult
        case .onDisconnected :return Constants.onDisconnected
        case .onEndpointFound :return Constants.onEndpointFound
        case .onEndpointLost :return Constants.onEndpointLost
        case .onPayloadReceived: return Constants.onPayloadReceived
        case .onPayloadTransferUpdate :return Constants.onPayloadTransferUpdate
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


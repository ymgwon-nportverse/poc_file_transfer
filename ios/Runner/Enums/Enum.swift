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

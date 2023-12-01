//
//  Constants.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#endif
import NearbyConnections


class Constants {
    static let methodChannelName = "nearby_connections"
    
    static let serviceId = "com.nportverse.poc"
    static let defaultStrategy = Strategy.pointToPoint
    static let defaultAdvertisingState = false
    static let defaultDiscoveryState = false
    static let bytePayload = ""

#if os(iOS) || os(watchOS) || os(tvOS)
    static let defaultEndpointName = UIDevice.current.name
#elseif os(macOS)
    static let defaultEndpointName = Host.current().localizedName ?? "Unknown macOS Device"
#else
    static let defaultEndpointName = "Unknown Device"
#endif
    
    // method call 부분 ( flutter -> ios)
    static let startDiscovery = "startDiscovery"
    static let startAdvertising = "startAdvertising"
    static let stopDiscovery = "stopDiscovery"
    static let stopAdvertising = "stopAdvertising"
    static let stopAllEndpoints = "stopAllEndpoints"
    static let disconnectFromEndpoint = "disconnectFromEndpoint"
    static let acceptConnection = "acceptConnection"
    static let requestConnection = "requestConnection"
    static let rejectConnection = "rejectConnection"
    static let sendPayload = "sendPayload"
    static let cancelPayload = "cancelPayload"
    
    
    // invokeMethod call 부분 ( ios -> flutter )
    static let  onConnectionInitiated  = "onConnectionInitiated"
    static let  onConnectionResult  = "onConnectionResult"
    static let  onDisconnected  = "onDisconnected"
    static let  onEndpointFound  = "onEndpointFound"
    static let  onEndpointLost  = "onEndpointLost"
    static let  onPayloadReceived  = "onPayloadReceived"
    static let  onPayloadTransferUpdate  = "onPayloadTransferUpdate"
}

//
//  FlutterMethodChannelHandler.swift
//  Runner
//
//  Created by ahhyun lee on 11/20/23.
//

import Foundation
import NearbyConnections
import UIKit
import Flutter

class StartDiscovery : FlutterNearbyMethodCallDelegate{
    
    let bridge: NearByConnectionHandler = NearByConnectionHandler()
    
    func callback(_ args: Dictionary<String, Any>?, channel: FlutterMethodChannel) {
        
        let userName = args?["userName"] as? String
        let strategy = args?["strategy"] as? Int
        let serviceId = args?["serviceId"] as? String
    
        bridge.invalidateDiscovery(isDiscoveryEnabled: true)
        
        // endpoint info , connection info
       // let arguments = ["endpointId": "test1","endpointName":"test2","authenticationDigits":"","isIncomingConnection":true] as Dictionary<String, Any>?
       // channel.invokeMethod(FlutterInvokeMethodEvent.onDiscoveryConnectionInitiated.eventName,arguments:arguments)
    }
    
    func printCallBackName(name: String) {
        print("printCallBackName => \(name)")
    }
}

class StartAdvertising :FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {    }
    
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}
class StopDiscovery :FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) { channel.invokeMethod(FlutterInvokeMethodEvent.onDiscoveryDisconnected.eventName, arguments: nil)}
    
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}
class StopAdvertising :FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {
        channel.invokeMethod(FlutterInvokeMethodEvent.onAdvertiseDisconnected.eventName, arguments: nil)
    }
    
    func printCallBackName(name: String) { print("callback name => \(name)")}
    
}
class StopAllEndpoints :FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel){channel.invokeMethod(FlutterInvokeMethodEvent.onEndpointLost.eventName, arguments: nil)}
    
    func printCallBackName(name: String) {print("callback name => \(name)")  }
    
}
class DisconnectFromEndpoint : FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {}
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}
class AcceptConnection : FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {}
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}
class RequestConnection : FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {}
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}
class RejectConnection : FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {}
    func printCallBackName(name: String) {print("callback name => \(name)")}
}

class SendPayload : FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {}
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}


class CancelPayload :FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {}
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}

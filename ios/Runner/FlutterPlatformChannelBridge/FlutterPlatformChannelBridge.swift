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

var nearByConnectionHandler:NearByConnectionHandler = NearByConnectionHandler()

class FlutterPlatformChannelBridge {
    var callName: FlutterNearbyMethodCallName?
    var args : Dictionary<String, Any>?
    var channel : FlutterMethodChannel
    
    init(callName: FlutterNearbyMethodCallName? = nil, args: Dictionary<String, Any>? = nil, channel: FlutterMethodChannel) {
        self.callName = callName
        self.args = args
        self.channel = channel
    }
    
  func  doAction(){
        callName?.methodCall.callback(args, channel: channel)
    }
    
}

class StartDiscovery : FlutterNearbyMethodCallDelegate{
    func callback(_ args: Dictionary<String, Any>?, channel: FlutterMethodChannel) {
        let userName = args?["userName"] as? String
        let strategy = args?["strategy"] as? Int
        let serviceId = args?["serviceId"] as? String
        nearByConnectionHandler.invalidateDiscovery(isEnabled: true)
        
    //todo invoke
    }
    
    func printCallBackName(name: String) {
        print("printCallBackName => \(name)")
    }
}

class StartAdvertising :FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) { 
        nearByConnectionHandler.invalidateAdvertising(isEnabled: true)
        
        //todo invoke
    }
    
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}
class StopDiscovery :FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {
        nearByConnectionHandler.invalidateDiscovery(isEnabled: false)
        channel.invokeMethod(FlutterInvokeMethodEvent.onDiscoveryDisconnected.eventName, arguments: nil)}
    
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}
class StopAdvertising :FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {
        nearByConnectionHandler.invalidateAdvertising(isEnabled: false)
        channel.invokeMethod(FlutterInvokeMethodEvent.onAdvertiseDisconnected.eventName, arguments: nil)
    }
    
    func printCallBackName(name: String) { print("callback name => \(name)")}
    
}
class StopAllEndpoints :FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel){
        nearByConnectionHandler.stopAllEndpoints()
        channel.invokeMethod(FlutterInvokeMethodEvent.onEndpointLost.eventName, arguments: nil)
    }
    
    func printCallBackName(name: String) {print("callback name => \(name)")  }
    
}
class DisconnectFromEndpoint : FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {
        let endpointId = args?["endpointId"] as? String
        nearByConnectionHandler.disconnect(from: endpointId!)
        
        channel.invokeMethod(FlutterInvokeMethodEvent.onEndpointLost.eventName, arguments: ["endpointId":endpointId])
    }
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}
class AcceptConnection : FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {
        let endpointId = args?["endpointId"] as? String
        nearByConnectionHandler.acceptEndPoint(ep: endpointId!)
        
        //todo invoke message  onPayloadReceived,
    }
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}
class RequestConnection : FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {
        let endpointId = args?["endpointId"] as? String
        nearByConnectionHandler.requestConnection(to: endpointId!)
        //todo invoke message
    }
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}
class RejectConnection : FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {
        nearByConnectionHandler.rejectConnection() // todo
    }
    func printCallBackName(name: String) {print("callback name => \(name)")}
}

class SendPayload : FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {
        let endpointId = args?["endpointId"] as? String
        nearByConnectionHandler.sendBytes(to: [endpointId!])
        
    }
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}


class CancelPayload :FlutterNearbyMethodCallDelegate{
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel) {
        let endpointId = args?["endpointId"] as? String
        nearByConnectionHandler.cancelPayload(to: [endpointId!])
    }
    func printCallBackName(name: String) {print("callback name => \(name)")}
    
}

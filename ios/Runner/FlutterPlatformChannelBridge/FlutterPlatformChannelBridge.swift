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

class FlutterPlatformChannelBridge {
    var callName: FlutterNearbyMethodCallName?
    var args : Dictionary<String, Any>?
    var channel : FlutterMethodChannel
    var result : FlutterResult
    
    init(callName: FlutterNearbyMethodCallName? = nil, args: Dictionary<String, Any>? = nil, channel: FlutterMethodChannel,result:@escaping FlutterResult) {
        self.callName = callName
        self.args = args
        self.channel = channel
        self.result = result
    }
    
    func  doAction(){
        print("🍏🍏🍏 callname => \(callName?.rawValue)")
        callName?.methodCall.callback(args, channel: channel,result: result)
    }
    
}

class StartAdvertising :FlutterNearbyMethodCallDelegate{
    
    var nearByConnectionController: NearByConnectionController = NearByConnectionController.shared
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel,result:@escaping FlutterResult) {
        nearByConnectionController.invalidateAdvertising(isEnabled: true)
        result(true)
    }
}

class StopAdvertising :FlutterNearbyMethodCallDelegate{
    
    var nearByConnectionController: NearByConnectionController = NearByConnectionController.shared
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel,result:@escaping FlutterResult) {
        nearByConnectionController.invalidateAdvertising(isEnabled: false)
        result(true)
    }
}

class StartDiscovery : FlutterNearbyMethodCallDelegate{
    
    var nearByConnectionController: NearByConnectionController = NearByConnectionController.shared
    
    func callback(_ args: Dictionary<String, Any>?, channel: FlutterMethodChannel,result:@escaping FlutterResult) {
        nearByConnectionController.invalidateDiscovery(isEnabled: true)
        result(true)
    }
}

class StopDiscovery :FlutterNearbyMethodCallDelegate{
    var nearByConnectionController: NearByConnectionController = NearByConnectionController.shared
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel,result:@escaping FlutterResult) {
        nearByConnectionController.invalidateDiscovery(isEnabled: false)
        result(true)
    }
}

class StopAllEndpoints :FlutterNearbyMethodCallDelegate{
    
    var nearByConnectionController: NearByConnectionController = NearByConnectionController.shared
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel,result:@escaping FlutterResult){
        nearByConnectionController.stopAllEndpoints()
        result(true)
    }
}

class DisconnectFromEndpoint : FlutterNearbyMethodCallDelegate{
    var nearByConnectionController: NearByConnectionController = NearByConnectionController.shared
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel,result:@escaping FlutterResult) {
        let endpointId = args?["endpointId"] as? String
        nearByConnectionController.disconnect(from: endpointId!)
        result(true)
    }
}

class AcceptConnection : FlutterNearbyMethodCallDelegate{
    
    var nearByConnectionController: NearByConnectionController = NearByConnectionController.shared
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel,result:@escaping FlutterResult) {
        let endpointId = args?["endpointId"] as? String
        nearByConnectionController.acceptEndPoint(endpointID: endpointId!)
        result(true)
    }
}

class RequestConnection : FlutterNearbyMethodCallDelegate{
    
    var nearByConnectionController: NearByConnectionController = NearByConnectionController.shared
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel,result:@escaping FlutterResult) {
        let endpointId = args?["endpointId"] as? String
        nearByConnectionController.requestConnection(to: endpointId!)
        result(true)
    }
}

class RejectConnection : FlutterNearbyMethodCallDelegate{
    
    var nearByConnectionController: NearByConnectionController = NearByConnectionController.shared
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel,result:@escaping FlutterResult) {
        let endpointId = args?["endpointId"] as? String
        // todo
        nearByConnectionController.rejection()
        result(true)
    }
    
}

class SendPayload : FlutterNearbyMethodCallDelegate{
    
    var nearByConnectionController: NearByConnectionController = NearByConnectionController.shared
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel,result:@escaping FlutterResult) {
        
        
        let endpointId = args?["endpointId"] as? String
          let rawPayload = args?["payload"] as? Dictionary<String, Any>
        //   let filePath = rawPayload?["filePath"] as? String
        // let myData = Data(bytes.data)
        let bytes = rawPayload?["bytes"] as!  FlutterStandardTypedData
        
        nearByConnectionController.sendPayload(to: [endpointId!], bytes: bytes)
        
        result(true)
        
    }
}

class CancelPayload :FlutterNearbyMethodCallDelegate{
    
    var nearByConnectionController: NearByConnectionController = NearByConnectionController.shared
    
    func callback(_ args: Dictionary<String, Any>?,channel: FlutterMethodChannel,result:@escaping FlutterResult) {
        let endpointId = args?["payloadId"] as? String
        //todo
        print("CancelPayload \(args)")
        // nearByConnectionController.cancelPayload(to: [endpointId!],bytes: nil)
        result(true)
    }
}


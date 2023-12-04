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


class NearbyConnectionsChannel : FlutterChannelDelegate {
    
    var nearByConnectionController: NearByConnectionController = NearByConnectionController.shared
    
    func callback(call: FlutterMethodCall, result: @escaping FlutterResult) {
        var args =  call.arguments as? Dictionary<String, Any>
        var method = call.method as String
        var endpointId:String?
        
        if((args?.keys.contains("endpointId")) != nil){
            endpointId = args?["endpointId"] as? String
        }
        print("args =>  \(String(describing: args))🍏🍏🍏 , method => \(method)")
        
        switch(method){
        case Constants.startAdvertising : return startAdvertising(result: result)
        case Constants.stopAdvertising: return stopAdvertising(result: result)
            
        case Constants.startDiscovery: return startDiscovery(result: result)
        case Constants.stopDiscovery : return stopDiscovery(result: result)
            
        case Constants.stopAllEndpoints: return stopAllEndpoints(result: result)
        case Constants.disconnectFromEndpoint: return disconnectFromEndpoint(endpointId: endpointId!, result: result)
            
        case Constants.acceptConnection : return acceptConnection(endpointId: endpointId!, result: result)
        case Constants.requestConnection: return requestConnection(endpointId: endpointId!, result: result)
        case Constants.rejectConnection: return rejectConnection(endpointId: endpointId!, result: result)
        case Constants.sendPayload :
            
            let rawPayload = args?["payload"] as! Dictionary<String, Any>
            
            return sendPayload(endpointId: endpointId!,rawPayload: rawPayload, result: result)
        case Constants.cancelPayload: return cancelPayload(payloadId: endpointId!,result: result)
            
        default:
            print("")
        }
    }
    
}

extension NearbyConnectionsChannel: NearbyConnectionsMethodCallEventDelegate{
    
    
    func startAdvertising(result: @escaping FlutterResult) {
        nearByConnectionController.invalidateAdvertising(isEnabled: true)
        result(true)
    }
    
    func stopAdvertising(result: @escaping FlutterResult) {
        nearByConnectionController.invalidateAdvertising(isEnabled: false)
        result(true)
    }
    
    func startDiscovery(result: @escaping FlutterResult) {
        nearByConnectionController.invalidateDiscovery(isEnabled: true)
        result(true)
    }
    
    func stopDiscovery(result: @escaping FlutterResult) {
        nearByConnectionController.invalidateDiscovery(isEnabled: false)
        result(true)
    }
    
    func stopAllEndpoints(result: @escaping FlutterResult) {
        nearByConnectionController.stopAllEndpoints()
        result(true)
    }
    
    func disconnectFromEndpoint(endpointId: String, result: @escaping FlutterResult) {
        nearByConnectionController.disconnect(from: endpointId)
        result(true)
    }
    
    func acceptConnection(endpointId: String, result: @escaping FlutterResult) {
        nearByConnectionController.acceptEndPoint(endpointID: endpointId)
        result(true)
    }
    
    func requestConnection(endpointId: String, result: @escaping FlutterResult) {
        nearByConnectionController.requestConnection(to: endpointId)
        result(true)
    }
    
    func rejectConnection(endpointId: String, result: @escaping FlutterResult) {
        nearByConnectionController.rejection()
        result(true)
    }
    
    func sendPayload(endpointId: String, rawPayload: Dictionary<String, Any>, result: @escaping FlutterResult) {
        let bytes = rawPayload["bytes"] as!  FlutterStandardTypedData
        nearByConnectionController.sendPayload(to: [endpointId], bytes: bytes)
    }
    
    func cancelPayload(payloadId: String, result: @escaping FlutterResult) {
        // todo
        
        result(true)
    }
    
}

class NearbyConnectionsInvokeEvent: NearbyConnectionsInvokeEventDelegate,InvokeMethodDelegate{
    
    func invokeMethod(method:FlutterInvokeMethodEvent,args:[String : Any]){
        FlutterChannelConnector.flutterMethodChannel?.invokeMethod(method.toString, arguments: args)
        
    }
    
    func onEndpointFound(endpointId: String, endpointName: String, serviceId: String){
        let args = [
            "endpointId":endpointId,"endpointName":endpointName,"serviceId":serviceId
        ]as [String : Any]
        invokeMethod(method: FlutterInvokeMethodEvent.onEndpointFound, args: args)
    }
    
    func onEndpointLost(endpointId: String) {
        let args = ["endpointId":endpointId] as [String : Any]
        invokeMethod(method: FlutterInvokeMethodEvent.onEndpointLost, args: args)
   }
    
    func onPayloadReceived(endpointId: String, payloadType: String, bytes: Data, payloadId: Int, filePath: String) {
        let args = ["endpointId":endpointId,"type": payloadType , "bytes" : bytes,"payloadId":payloadId, "filePath":filePath ] as [String : Any]
        invokeMethod(method: FlutterInvokeMethodEvent.onPayloadReceived, args: args)
    }
    
    func onPayloadTransferUpdate(endpointId: String, payloadId: Int64, payloadStatus: String, bytesTransferred: Int, totalBytes: Int) {
        let args = ["endpointId":endpointId,"payloadId":payloadId,"status":payloadStatus,",bytesTransferred":bytesTransferred,"totalBytes":totalBytes] as [String : Any]
        invokeMethod(method: FlutterInvokeMethodEvent.onPayloadTransferUpdate, args: args)
    }
    
    func onConnectionInitiated(endpointId: String, endpointName: String, authenticationDigits: String, isIncomingConnection: Bool) {
        let args = ["endpointId":endpointId,"endpointName":endpointName,"authenticationDigits":authenticationDigits,"isIncomingConnection":isIncomingConnection]as [String : Any]
        invokeMethod(method: FlutterInvokeMethodEvent.onConnectionInitiated ,args: args)
   }
    
    func onConnectionResult(endpointId: String, status: ConnectionStatus) {
        let args = ["endpointId":endpointId,"statusCode":status.rawValue]as [String : Any]
        invokeMethod(method: FlutterInvokeMethodEvent.onConnectionResult, args: args)
   }
    
    func onDisconnected(endpointId: String) {
        let args = ["endpointId":endpointId] as [String : Any]
        invokeMethod(method: FlutterInvokeMethodEvent.onDisconnected, args: args)
    }
    

}

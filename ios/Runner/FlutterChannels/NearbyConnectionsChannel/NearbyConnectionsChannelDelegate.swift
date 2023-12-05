//
//  NearbyMethodCallDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 11/20/23.
//
import Flutter
import Foundation

protocol NearbyConnectionsMethodCallEventDelegate{
    
    func startAdvertising(result:@escaping FlutterResult)
    
    func stopAdvertising(result:@escaping FlutterResult)
    
    func startDiscovery(result:@escaping FlutterResult)
    
    func stopDiscovery(result:@escaping FlutterResult)
    
    func stopAllEndpoints(result:@escaping FlutterResult)
    
    func disconnectFromEndpoint(endpointId:String,result:@escaping FlutterResult)
    
    func acceptConnection(endpointId:String,result:@escaping FlutterResult)
    
    func requestConnection(endpointId:String,result:@escaping FlutterResult)
    
    func rejectConnection(endpointId:String,result:@escaping FlutterResult)
    
    func sendPayload(endpointId:String,rawPayload: Dictionary<String, Any>,result:@escaping FlutterResult)
    
    func cancelPayload(payloadId:String,result:@escaping FlutterResult)
}

protocol NearbyConnectionsInvokeEventDelegate{
    
    func onEndpointFound (endpointId:String, endpointName:String, serviceId:String)
    
    func onEndpointLost(endpointId:String)
    
    func onPayloadReceived(endpointId:String,payloadType:String,bytes:Data,payloadId:Int,filePath:String?)
    
    func onPayloadTransferUpdate(endpointId:String,payloadId:Int64,payloadStatus:String,bytesTransferred:Int,totalBytes:Int)
    
    func onConnectionInitiated(endpointId:String,endpointName:String, authenticationDigits:String,isIncomingConnection:Bool)
    
    func onConnectionResult(endpointId:String,status:ConnectionStatus)
    
    func onDisconnected(endpointId:String)
}


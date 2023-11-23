//
//  NearbyMethodCallDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 11/20/23.
//
import Flutter
import Foundation


// 정리 필요 
protocol FlutterNearbyMethodCallDelegate{
    
//    @objc optional func startDiscovery(_ userName:String,strategy:String, serviceId:String) - ok
//
//    @objc optional func startAdvertising(_ userName:String,strategy:String, serviceId:String,onBandwidthChanged:()->(),onConnectionInitiated:()->(),onConnectionResult:()->(),onDisconnected:()->()) - ok
//
//    @objc optional func stopDiscovery() - ok
//
//    @objc optional func stopAdvertising() - ok
//
//    @objc optional func stopAllEndpoints() - ok
//
//    @objc optional func disconnectFromEndpoint(_ endpointId:String) - ok
//
//    @objc optional func acceptConnection(_  endpointId:String,onPayloadReceived:()->(),onPayloadTransferUpdate:()->()) - ok
//
//    @objc optional func  requestConnection(_ userName:String,endpointId:String,onBandwidthChanged:()->(),onConnectionInitiated:()->(),onConnectionResult:()->(),onDisconnected:()->()) - ok
//
//    @objc optional func rejectConnection(_ endpointId:String) - todo
//
//    //   @objc optional func sendPayload(_ endpointId:String, paylodad :Payload) - ok
//
//    @objc optional func cancelPayload(_ payloadId:String) - ok 
//
    
    func  callback(_ args: Dictionary<String, Any>?, channel : FlutterMethodChannel)
    
}



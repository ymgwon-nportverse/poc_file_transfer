//
//  NearbyMethodCallDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 11/20/23.
//
import Flutter
import Foundation


// 정리 필요 
@objc protocol FlutterNearbyMethodCallDelegate{
    
    @objc optional func startDiscovery(_ userName:String,strategy:String, serviceId:String)
    
    @objc optional func startAdvertising(_ userName:String,strategy:String, serviceId:String,onBandwidthChanged:()->(),onConnectionInitiated:()->(),onConnectionResult:()->(),onDisconnected:()->())
    
    @objc optional func stopDiscovery()
    
    @objc optional func stopAdvertising()
    
    @objc optional func stopAllEndpoints()
    
    @objc optional func disconnectFromEndpoint(_ endpointId:String)
    
    @objc optional func acceptConnection(_ endpointId:String,onPayloadReceived:()->(),onPayloadTransferUpdate:()->())
    
    @objc optional func  requestConnection(_ userName:String,endpointId:String,onBandwidthChanged:()->(),onConnectionInitiated:()->(),onConnectionResult:()->(),onDisconnected:()->())
    
    @objc optional func rejectConnection(_ endpointId:String)
    
    //   @objc optional func sendPayload(_ endpointId:String, paylodad :Payload)
    
    @objc optional func cancelPayload(_ payloadId:String)
    
    @objc func printCallBackName(name:String)
    
    @objc func  callback(_ args: Dictionary<String, Any>?, channel : FlutterMethodChannel)
    
    @objc optional func invokeMethod()
    
    @objc optional var args:  Dictionary<String, Any> { get }
    
    @objc optional var channel: FlutterMethodChannel { get }
    
    //    @objc var bridge: FlutterPlatformChannelBridge { get }
}



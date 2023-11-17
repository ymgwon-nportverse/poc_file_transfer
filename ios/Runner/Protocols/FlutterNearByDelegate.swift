//
//  FlutterChannelBridge.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//
import Flutter
import Foundation


extension FlutterNearByDelegate {
    // 익스텐션을 통해 Optional Function에 미리 기본값을 반환하게끔 한다.
    
}



// method.call, method.invoke 나누기
 protocol FlutterNearByDelegate {
    
    // method.call 부분
    //startDiscovery
     func startDiscovery(userName:String,strategy:String, serviceId:String,onEndpointFound:()->(),onEndpointLost:()->()) // function 부분 OnEndpointFound onEndpointFound,OnEndpointLost onEndpointLost,
    
    //startAdvertising
     func startAdvertising(userName:String,strategy:String, serviceId:String,onBandwidthChanged:()->(),onConnectionInitiated:()->(),onConnectionResult:()->(),onDisconnected:()->())
    
    //stopDiscovery
    func stopDiscovery() // none
    
    //stopAdvertising
     func stopAdvertising() // none
    
    //stopAllEndpoints
     func stopAllEndpoints() // none
    
    //disconnectFromEndpoint
     func disconnectFromEndpoint(endpointId:String)
    
    //acceptConnection
     func acceptConnection(endpointId:String,onPayloadReceived:()->(),onPayloadTransferUpdate:()->())
    
    //requestConnection
     func requestConnection(userName:String,endpointId:String,onBandwidthChanged:()->(),onConnectionInitiated:()->(),onConnectionResult:()->(),onDisconnected:()->())
    
    //rejectConnection
     func rejectConnection(endpointId:String)
    
    //sendPayload
     func sendPayload(endpointId:String, paylodad :Payload)
    
    //cancelPayload
    func cancelPayload(payloadId:String)
    
    //------------------------------------------------------------------------------------------------------------------------
    
    
    // method.invoke 부분
    func onConnectionInitiated(endpointId:String,connectionInfo:ConnectionInfo)
    
    func onBandwidthChanged(endpointId:String,quality:BandwidthQuality ) // ok
    
    func onConnectionResult(endpointId:String, status: ConnectionStatus) // ok
    
    func onDisconnected(endpointId:String) // ok
    
    func onPayloadReceived(endpointId:String, payload:Payload) // ok
    
    func onEndpointFound(endpointId:String,endpointName:String,serviceId:String) // ok
    
    func onEndpointLost(endpointId:String?) // ok
    
    func onPayloadTransferUpdate(endpointId:String, payloadTransferUpdate:PayloadTransferUpdate) // ok
    
}

//
//  NearbyMethodInvokeDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 11/20/23.
//

import Foundation

protocol FlutterNearbyMethodInvokeDelegate {
    
    func onConnectionInitiated(_ endpointId:String,connectionInfo:ConnectionInfo)
    
    func onBandwidthChanged(_ endpointId:String,quality:BandwidthQuality )
    
    func onConnectionResult(_ endpointId:String, status: ConnectionStatus)
    
    func onDisconnected(_ endpointId:String)
    
    func onPayloadReceived(_ endpointId:String, payload:Payload)
    
    func onEndpointFound(_ endpointId:String,endpointName:String,serviceId:String)
    
    func onEndpointLost(_ endpointId:String?)
    
    func onPayloadTransferUpdate(_ endpointId:String, payloadTransferUpdate:PayloadTransferUpdate)
    
    
}

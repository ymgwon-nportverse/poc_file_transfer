//
//  FlutterChannelBridge.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//
import Flutter
import Foundation

//let controller : FlutterViewController = window?.rootViewController as! //FlutterViewController
//let channel = FlutterMethodChannel(name: "nportverse_nearby_method_channel", //binaryMessenger: controller.binaryMessenger)


class EventHandler:NSObject, FlutterStreamHandler {

    var eventSink: FlutterEventSink?
    
    var queuedLinks = [String: Any?]()

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        queuedLinks.forEach({ events($0) })
        queuedLinks.removeAll()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    func handleEndpoint(_ endpoint: [String: Any?]) -> Bool {
        guard let eventSink = eventSink else {
          //  queuedLinks.append(endpoint)
            return false
        }
        eventSink(endpoint)
        return true
    }
    
    func handlePayLoadData(_  arguments: Any?) -> Bool {
        guard let eventSink = eventSink else {
          //  queuedLinks.append(endpoint)
            return false
        }
        eventSink(arguments)
        return true
    }
}
//channel.setMethodCallHandler({
//    (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
//    
//    switch(call.method) {
//    case "getNearbyOnOffState":
//            if let args = call.arguments as? Dictionary<String, Any> {
//                                 if let mode = args["mode"] as? String {
//                                     if let isEnabled = args["isEnabled"] as? Bool {
//                                         if(mode == "sender"){
//                                             invalidateSending(isEnabled: !isEnabled)
//                                         }else{
//                                             invalidateReceiving(isEnabled: !isEnabled)
//                                         }
//                                      
//                                     }
//                  
//                                 }
//                             }
//  
//        break
//    case "shouldAccept":
//        if let args = call.arguments as? Dictionary<String, Any> {
//                             if let endpointID = args["endpointID"] as? String{
//                                 self.acceptEndPoint(ep: endpointID)
//                                 result(true)
//                             }
//                         }
//        break
//    case "sendBytes":
//        if let args = call.arguments as? Dictionary<String, Any> {
//            if let endpointID = args["endpointID"] as? String{
//                   self.sendBytes(to: [endpointID])
//                result(true)
//            }
//                         }
//        break
//    default :
//        break
//    }
//    
//})

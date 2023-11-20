//
//  flutterChannel.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import Flutter
//import Swinject
import UIKit


public class FlutterPlatformChannel{
    public let channelName: String
    public let flutterWindow: UIWindow!
    
    public init(channelName: String,flutterWindow: UIWindow!) {
        self.flutterWindow = flutterWindow
        self.channelName = channelName
   }
    
   func flutterMethodChannel()-> FlutterMethodChannel {
        let controller : FlutterViewController = flutterWindow?.rootViewController as! FlutterViewController
        let result = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
        return  result
    }
    
    
    func FlutterMethodCallBack (){
        self.flutterMethodChannel().setMethodCallHandler({
                (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                print("call.method => \(call.method)")
            })
    
    }
    
    func FlutterInvokeMethod (){
       // self.flutterMethodChannel().invokeMethod(<#T##method: String##String#>, arguments: <#T##Any?#>)
    
    }
    
}

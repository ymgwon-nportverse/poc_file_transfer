//
//  flutterChannel.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import Flutter
import UIKit
import OSLog

public class FlutterChannelConnector : FlutterChannelConnectorDelegate,FlutterChannelMethodCallDelegate{
    
    static var flutterMethodChannel:FlutterMethodChannel?
    var flutterViewController: FlutterViewController
    var channelName: String
    var flutterChannel :FlutterChannelDelegate
        
    init(flutterViewController: FlutterViewController, channelName: String,flutterChannel : FlutterChannelDelegate
    ) {
        self.flutterViewController = flutterViewController
        self.channelName = channelName
        self.flutterChannel = flutterChannel
        FlutterChannelConnector.flutterMethodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: flutterViewController.binaryMessenger)
    }
    
    
    func setMethodCallHandler(){
        do{
           try FlutterChannelConnector.flutterMethodChannel?.setMethodCallHandler(self.handler)
            os_log("[FlutterChannelConnector_setMethodCallHandler] result = success")
        }catch{
            os_log(.error, log: .default, "[FlutterChannelConnector_setMethodCallHandler]__\(error)")
        }
    }
    
    var handler: FlutterMethodCallHandler {
        return {(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self.flutterChannel.callback(call: call, result: result)
            
        }
    }
}

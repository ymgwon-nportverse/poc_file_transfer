//
//  ChannelDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 11/20/23.
//

import Foundation
import Flutter
import UIKit

protocol FlutterPlatformChannelDelegate {
    
    var flutterViewController:FlutterViewController! { get }
    
    var flutterMethodChannel :FlutterMethodChannel! { get } 
    
    func callHandler() 
    
}


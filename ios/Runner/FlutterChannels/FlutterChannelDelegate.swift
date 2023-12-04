//
//  FlutterChannelDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 12/4/23.
//

import Foundation
import Flutter
import UIKit

protocol FlutterChannelDelegate{

    func callback(call: FlutterMethodCall, result: @escaping FlutterResult)
    
}

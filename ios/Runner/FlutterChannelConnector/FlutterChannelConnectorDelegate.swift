//
//  FlutterPlatformDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 12/1/23.
//

import Foundation
import Flutter
import UIKit

protocol FlutterChannelConnectorDelegate{
    var flutterViewController: FlutterViewController { get  }
    var channelName : String { get }
    static var flutterMethodChannel: FlutterMethodChannel? { get }
}

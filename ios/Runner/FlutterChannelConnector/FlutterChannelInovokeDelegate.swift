//
//  FlutterChannelInovokeDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 12/4/23.
//

import Foundation
import Flutter
import UIKit

protocol InvokeMethodDelegate{
    func invokeMethod(method:FlutterInvokeMethodEvent,args:[String : Any])
}

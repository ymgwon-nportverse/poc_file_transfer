//
//  NearbyMethodCallDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 11/20/23.
//
import Flutter
import Foundation

 
protocol FlutterNearbyMethodCallDelegate{

    func callback(_ args: Dictionary<String, Any>?, channel : FlutterMethodChannel, result:@escaping FlutterResult)
    var nearByConnectionController:NearByConnectionController{get}
}



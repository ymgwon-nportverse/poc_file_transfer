//
//  Constants.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#endif
import NearbyConnections


class Constants {
    static let serviceId = "com.nportverse.poc"
    static let defaultStrategy = Strategy.star
    static let defaultAdvertisingState = false
    static let defaultDiscoveryState = false
    static let bytePayload = "hello world"
    
#if os(iOS) || os(watchOS) || os(tvOS)
    static let defaultEndpointName = UIDevice.current.name
#elseif os(macOS)
    static let defaultEndpointName = Host.current().localizedName ?? "Unknown macOS Device"
#else
    static let defaultEndpointName = "Unknown Device"
#endif
}

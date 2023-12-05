//
//  AdvertiserDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections
import OSLog

extension NearByConnectionController : AdvertiserDelegate {
    func advertiser(_ advertiser: Advertiser, didReceiveConnectionRequestFrom endpointID: EndpointID, with context: Data, connectionRequestHandler: @escaping (Bool) -> Void) {

        guard let endpointName = String(data: context, encoding: .utf8) else {
            os_log("[AdvertiserDelegate] \(endpointID)")
            return
        }
        
        let endpoint = DiscoveredEndpoint(
            id: UUID(),
            endpointID: endpointID,
            endpointName: endpointName
        )
        endpoints.insert(endpoint, at: 0)
        connectionRequestHandler(true)
        
        os_log("[AdvertiserDelegate]__connection success!")
    }
    
}

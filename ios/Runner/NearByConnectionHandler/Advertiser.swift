//
//  AdvertiserDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections


extension NearByConnectionHandler : AdvertiserDelegate {
    func advertiser(_ advertiser: Advertiser, didReceiveConnectionRequestFrom endpointID: EndpointID, with context: Data, connectionRequestHandler: @escaping (Bool) -> Void) {
        guard let endpointName = String(data: context, encoding: .utf8) else {
            return
        }
        
        let endpoint = DiscoveredEndpoint(
            id: UUID(),
            endpointID: endpointID,
            endpointName: endpointName
        )
        endpoints.insert(endpoint, at: 0)
        let endpointInfo: [String: Any?] = ["id": UUID().uuidString,"endpointID": endpointID,"endpointName":endpointName]
        
        connectionRequestHandler(true)
    }
}

//
//  DiscovererDelegater.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections

extension NearByConnectionHandler: DiscovererDelegate {
    func discoverer(_ discoverer: Discoverer, didFind endpointID: EndpointID, with context: Data) {
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
        
        requestConnection(to: endpointID)
    }
    
    func discoverer(_ discoverer: Discoverer, didLose endpointID: EndpointID) {
        guard let index = endpoints.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        endpoints.remove(at: index)
    }
}

//
//  DiscovererDelegater.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections

extension NearByConnectionController: DiscovererDelegate {
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
        
        if(endpoints.isEmpty){
            // 분기처리 필요 found / lost (중복 처리도 적용)
        }else{
            nearbyConnectionsInvokeEvent.onEndpointFound(endpointId: endpointID, endpointName: endpointName, serviceId: Constants.serviceId)
        }
       
    }
    
    func discoverer(_ discoverer: Discoverer, didLose endpointID: EndpointID) {
        guard let index = endpoints.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        
        nearbyConnectionsInvokeEvent.onEndpointLost(endpointId: endpointID)
        endpoints.remove(at: index)
    }
}

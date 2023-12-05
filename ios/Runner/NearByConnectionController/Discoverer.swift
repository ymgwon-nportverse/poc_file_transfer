//
//  DiscovererDelegater.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections
import OSLog

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
            os_log("[DiscovererDelegate]: endpoint is empty!! ")
        }else{
            nearbyConnectionsInvokeEvent.onEndpointFound(endpointId: endpointID, endpointName: endpointName, serviceId: Constants.serviceId)
            os_log("[DiscovererDelegate]__onEndpointFound success !! ")
        }
       
    }
    
    func discoverer(_ discoverer: Discoverer, didLose endpointID: EndpointID) {
        guard let index = endpoints.firstIndex(where: { $0.endpointID == endpointID }) else {
            os_log("[DiscovererDelegate] \(endpointID)")
            
            return
        }
        
        nearbyConnectionsInvokeEvent.onEndpointLost(endpointId: endpointID)
        endpoints.remove(at: index)
        os_log("[DiscovererDelegate]__onEndpointLost !!")
    }
}

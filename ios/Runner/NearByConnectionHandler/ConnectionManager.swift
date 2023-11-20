//
//  connectionManager.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections

extension NearByConnectionHandler : ConnectionManagerDelegate {
    
    func connectionManager(
        _ connectionManager: ConnectionManager, didReceive verificationCode: String,
        from endpointID: EndpointID, verificationHandler: @escaping (Bool) -> Void){
            guard let index = endpoints.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            let endpoint = endpoints.remove(at: index)
            let request = ConnectionRequest(
                id: endpoint.id,
                endpointID: endpointID,
                endpointName: endpoint.endpointName,
                pin: verificationCode,
                shouldAccept: { accept in
                    verificationHandler(accept)
                }
            )
            requests.insert(request, at: 0)
        }
    
    func connectionManager(
        _ connectionManager: ConnectionManager, didReceive data: Data, withID payloadID: PayloadID,
        from endpointID: EndpointID){
        }
    
    func connectionManager(
        _ connectionManager: ConnectionManager, didReceive stream: InputStream,
        withID payloadID: PayloadID,
        from endpointID: EndpointID, cancellationToken token: CancellationToken){
        }
    
    func connectionManager(
        _ connectionManager: ConnectionManager, didStartReceivingResourceWithID payloadID: PayloadID,
        from endpointID: EndpointID, at localURL: URL, withName name: String,
        cancellationToken token: CancellationToken){
        }
    func connectionManager(
        _ connectionManager: ConnectionManager, didReceiveTransferUpdate update: TransferUpdate,
        from endpointID: EndpointID, forPayload payloadID: PayloadID){
        }
    func connectionManager(
        _ connectionManager: ConnectionManager, didChangeTo state: ConnectionState,
        for endpointID: EndpointID
    ){
        switch (state) {
        case .connecting:
            break
        case .connected:
            guard let index = requests.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            let request = requests.remove(at: index)
            let connection = ConnectedEndpoint(
                id: request.id,
                endpointID: endpointID,
                endpointName: request.endpointName
            )
            connections.insert(connection, at: 0)
        case .disconnected:
            guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            connections.remove(at: index)
        case .rejected:
            guard let index = requests.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            requests.remove(at: index)
        }
    }
    
}

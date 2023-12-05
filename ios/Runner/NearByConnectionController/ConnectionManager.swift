//
//  connectionManager.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections
import OSLog

extension NearByConnectionController: ConnectionManagerDelegate {
    
    func connectionManager(_ connectionManager: ConnectionManager, didReceive verificationCode: String, from endpointID: EndpointID, verificationHandler: @escaping (Bool) -> Void) {
        
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
        //verificationHandler(true)
        os_log("[connectionManager]__Optionally show the user the verification code. Your app should call this handler with a value of `true` if the nearby endpoint should be trusted, or `false` otherwise.")
    }
    
    func connectionManager(_ connectionManager: ConnectionManager, didReceive data: Data, withID payloadID: PayloadID, from endpointID: EndpointID) {
        let payload = Payload(
            id: payloadID,
            type: .bytes,
            payloadStatus: .success,
            isIncoming: true,
            cancellationToken: nil
        )
        
        guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        
        connections[index].payloads.insert(payload, at: 0)
        nearbyConnectionsInvokeEvent.onPayloadReceived(endpointId: endpointID, payloadType: payload.type.toString, bytes: data, payloadId: Int(payloadID), filePath: "")
        nearbyConnectionsInvokeEvent.onPayloadTransferUpdate(endpointId: endpointID, payloadId: payloadID, payloadStatus: payload.payloadStatus.toString, bytesTransferred: data.count, totalBytes: data.count)
        
        os_log("[connectionManager]__[onPayloadReceived and onPayloadTransferUpdate] A simple byte payload has been received. This will always include the full data.")
    }
    
    
    func connectionManager(_ connectionManager: ConnectionManager, didReceive stream: InputStream, withID payloadID: PayloadID, from endpointID: EndpointID, cancellationToken token: CancellationToken) {
        let payload = Payload(
            id: payloadID,
            type: .stream,
            payloadStatus: .success,
            isIncoming: true,
            cancellationToken: token
        )
        
        guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        
        connections[index].payloads.insert(payload, at: 0)
        os_log("[connectionManager]__ We have received a readable stream.")
    }
    
 // todo
    func connectionManager(_ connectionManager: ConnectionManager, didStartReceivingResourceWithID payloadID: PayloadID, from endpointID: EndpointID, at localURL: URL, withName name: String, cancellationToken token: CancellationToken) {
        let payload = Payload(
            id: payloadID,
            type: .file,
            payloadStatus: .inProgress,
            isIncoming: true,
            cancellationToken: token
        )
        
        guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        connections[index].payloads.insert(payload, at: 0)
        os_log("[connectionManager]__ We have started receiving a file. We will receive a separate transfer update event when complete.")
    }
    
    func connectionManager(_ connectionManager: ConnectionManager, didReceiveTransferUpdate update: TransferUpdate, from endpointID: EndpointID, forPayload payloadID: PayloadID) {
        guard let connectionIndex = connections.firstIndex(where: { $0.endpointID == endpointID }),
              let payloadIndex = connections[connectionIndex].payloads.firstIndex(where: { $0.id == payloadID }) else {
            return
        }
        
        switch update {
        case .success:
            connections[connectionIndex].payloads[payloadIndex].payloadStatus = .success
        case .canceled:
            connections[connectionIndex].payloads[payloadIndex].payloadStatus = .canceled
        case .failure:
            connections[connectionIndex].payloads[payloadIndex].payloadStatus = .failure
        case let .progress(progress):
            connections[connectionIndex].payloads[payloadIndex].payloadStatus = .inProgress
        }
        
        os_log("[connectionManager : payload state]__ A success, failure, cancelation or progress update.")
    }
    
    
    func connectionManager(_ connectionManager: ConnectionManager, didChangeTo state: ConnectionState, for endpointID: EndpointID) {
        switch (state) {
        case .connecting:
            nearbyConnectionsInvokeEvent.onConnectionInitiated(endpointId: endpointID, endpointName: endpointName ,authenticationDigits: "", isIncomingConnection: true)
            os_log("[connectionManager ]__[onConnectionInitiated] A connection to the remote endpoint is currently being established.")
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
            nearbyConnectionsInvokeEvent.onConnectionResult(endpointId: endpointID, status: ConnectionStatus.connected)
            os_log("[connectionManager]__[onConnectionResult] We're connected! Can now start sending and receiving data.")
        case .disconnected:
            
            guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            //           connections.remove(at: index)
            connections.removeAll()
            nearbyConnectionsInvokeEvent.onDisconnected(endpointId: endpointID)
            os_log("[connectionManager]__[onDisconnected] We've been disconnected from this endpoint. No more data can be sent or received.")
        case .rejected:
            
            guard let index = requests.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            os_log("[connectionManager]__[reject] The connection was rejected by one or both sides.")
            requests.remove(at: index)
        }
    }
}

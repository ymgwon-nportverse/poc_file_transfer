//
//  connectionManager.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections

extension NearbyConnectionManager : ConnectionManagerDelegate {
    
    func connectionManager(
      _ connectionManager: ConnectionManager, didReceive verificationCode: String,
      from endpointID: EndpointID, verificationHandler: @escaping (Bool) -> Void){
          
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
        
    }
    
}

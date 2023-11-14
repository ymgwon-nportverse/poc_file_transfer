import NearbyConnections

extension NearbyHandler : AdvertiserDelegate {
    func advertiser(
       _ advertiser: Advertiser, didReceiveConnectionRequestFrom endpointID: EndpointID,
       with context: Data, connectionRequestHandler: @escaping (Bool) -> Void) {
       // Accept or reject any incoming connection requests. The connection will still need to
       // be verified in the connection manager delegate.
       connectionRequestHandler(true)
     }
}

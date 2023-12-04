import NearbyConnections

extension NearbyMethodCallHandler: AdvertiserDelegate {
    func advertiser(
        _: Advertiser, didReceiveConnectionRequestFrom endpointId: EndpointID,
        with context: Data, connectionRequestHandler: @escaping (Bool) -> Void
    ) {
        // Accept or reject any incoming connection requests. The connection will still need to
        // be verified in the connection manager delegate.
        print("Let's test what this is")
        guard let endpointName = String(data: context, encoding: .utf8) else {
            return
        }
        print("endpointId: \(endpointId)")
        print("endpointName: \(endpointName)")
        connectionRequestHandler(true)
    }
}

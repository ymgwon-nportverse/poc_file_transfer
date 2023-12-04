import NearbyConnections

extension NearbyMethodCallHandler: ConnectionManagerDelegate {
    func connectionManager(
        _: ConnectionManager, didReceive verificationCode: String,
        from endpointId: EndpointID, verificationHandler: @escaping (Bool) -> Void
    ) {
        // Optionally show the user the verification code. Your app should call this handler
        // with a value of `true` if the nearby endpoint should be trusted, or `false`
        // otherwise.
        print("onConnectionInitiated")
        var args = [String: Any]()
        args["endpointId"] = endpointId
        // TODO: handle this
        // args["endpointName"] = connectionInfo.endpointName
        args["authenticationDigits"] = verificationCode
        verificationHandler(true)
    }

    func connectionManager(
        _: ConnectionManager, didReceive _: Data,
        withID _: PayloadID, from _: EndpointID
    ) {
        // A simple byte payload has been received. This will always include the full data.
    }

    func connectionManager(
        _: ConnectionManager, didReceive _: InputStream,
        withID _: PayloadID, from _: EndpointID,
        cancellationToken _: CancellationToken
    ) {
        // We have received a readable stream.
    }

    func connectionManager(
        _: ConnectionManager,
        didStartReceivingResourceWithID _: PayloadID,
        from _: EndpointID, at _: URL,
        withName _: String, cancellationToken _: CancellationToken
    ) {
        // We have started receiving a file. We will receive a separate transfer update
        // event when complete.
    }

    func connectionManager(
        _: ConnectionManager,
        didReceiveTransferUpdate _: TransferUpdate,
        from _: EndpointID, forPayload _: PayloadID
    ) {
        // A success, failure, cancellation or progress update.
    }

    func connectionManager(
        _: ConnectionManager, didChangeTo state: ConnectionState,
        for _: EndpointID
    ) {
        switch state {
        case .connecting:
            // A connection to the remote endpoint is currently being established.
            print("connecting")
        case .connected:
            // We're connected! Can now start sending and receiving data.
            print("connected")
        case .disconnected:
            // We've been disconnected from this endpoint. No more data can be sent or received.
            print("disconnected")
        case .rejected:
            // The connection was rejected by one or both sides.
            print("rejected")
        }
    }
}

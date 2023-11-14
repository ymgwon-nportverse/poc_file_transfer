import Flutter
import NearbyConnections

extension NearbyHandler: DiscovererDelegate{
    func discoverer(
        _ discoverer: Discoverer, didFind endpointID: EndpointID, with context: Data) {
        // An endpoint was found.
        print("onEndpointFound")
        var args = [String:Any]()
        guard let endpointName = String(data: context, encoding: .utf8) else {
            return
        }
        args["endpointId"] = endpointID.data(using: .utf8)
        args["endpointName"] = endpointName
        /// xcode에 익숙하지 않아서 어디 정볼를 물고 있는지 찾기 힘듬 . 없으면 안넣어도 크게 상관 없을듯
        // args["serviceId"] = discoveredEndpointInfo.serviceId
        methodChannel.invokeMethod("onEndpointFound", arguments: args)
      }

      func discoverer(_ discoverer: Discoverer, didLose endpointID: EndpointID) {
        // A previously discovered endpoint has gone away.
        print("onEndpointLost")
        var args = [String:Any]()
        args["endpointId"] = endpointID.data(using: .utf8)
        methodChannel.invokeMethod("onEndpointLost", arguments: args)
      }
}

package com.nportverse.poc

import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.connection.AdvertisingOptions
import com.google.android.gms.nearby.connection.ConnectionInfo
import com.google.android.gms.nearby.connection.ConnectionLifecycleCallback
import com.google.android.gms.nearby.connection.ConnectionResolution
import com.google.android.gms.nearby.connection.ConnectionsStatusCodes
import com.google.android.gms.nearby.connection.DiscoveredEndpointInfo
import com.google.android.gms.nearby.connection.DiscoveryOptions
import com.google.android.gms.nearby.connection.EndpointDiscoveryCallback
import com.google.android.gms.nearby.connection.Payload
import com.google.android.gms.nearby.connection.PayloadCallback
import com.google.android.gms.nearby.connection.PayloadTransferUpdate
import com.google.android.gms.nearby.connection.Strategy
import com.google.android.gms.tasks.OnSuccessListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileNotFoundException

const val SERVICE_ID = "com.nportverse.poc"

const val NEARBY_METHOD_CHANNEL = "nearby_connections"

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
    private lateinit var nearbyChannel: MethodChannel

    override fun configureFlutterEngine(
        @NonNull flutterEngine: FlutterEngine,
    ) {
        super.configureFlutterEngine(flutterEngine)

        nearbyChannel =
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                NEARBY_METHOD_CHANNEL,
            )

        nearbyChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        try {
            when (call.method) {
                "stopAdvertising" -> {
                    Log.d("nearby_connections", "stopAdvertising")
                    Nearby.getConnectionsClient(this).stopAdvertising()
                    result.success(null)
                }

                "stopDiscovery" -> {
                    Log.d("nearby_connections", "stopDiscovery")
                    Nearby.getConnectionsClient(this).stopDiscovery()
                    result.success(null)
                }

                "startAdvertising" -> {
                    val userName = call.argument<Any>("userName") as String?
                    val strategy = call.argument<Any>("strategy") as Int
                    var serviceId = call.argument<Any>("serviceId") as String?
                    assert(userName != null)
                    if (serviceId == null || serviceId === "") {
                        serviceId = SERVICE_ID
                    }
                    val advertisingOptions =
                        AdvertisingOptions.Builder().setStrategy(getStrategy(strategy)).build()
                    Nearby.getConnectionsClient(this).startAdvertising(
                        (userName)!!,
                        serviceId,
                        advertiseConnectionLifecycleCallback,
                        advertisingOptions,
                    ).addOnSuccessListener(
                        OnSuccessListener {
                            Log.d("nearby_connections", "startAdvertising")
                            Log.d("nearby_connections", "serviceId: $serviceId")
                            result.success(true)
                        },
                    ).addOnFailureListener { e ->
                        result.error(
                            "Failure",
                            e.message,
                            null,
                        )
                    }
                }

                "startDiscovery" -> {
                    val userName = call.argument<Any>("userName") as String?
                    val strategy = call.argument<Any>("strategy") as Int
                    var serviceId = call.argument<Any>("serviceId") as String?
                    assert(userName != null)
                    if (serviceId == null || serviceId === "") {
                        serviceId = SERVICE_ID
                    }
                    val discoveryOptions =
                        DiscoveryOptions.Builder().setStrategy(getStrategy(strategy)).build()
                    Nearby.getConnectionsClient(this)
                        .startDiscovery(serviceId, endpointDiscoveryCallback, discoveryOptions)
                        .addOnSuccessListener {
                            Log.d("nearby_connections", "startDiscovery")
                            Log.d("nearby_connections", "serviceId: $serviceId")
                            result.success(true)
                        }.addOnFailureListener { e ->
                            result.error(
                                "Failure",
                                e.message,
                                null,
                            )
                        }
                }

                "stopAllEndpoints" -> {
                    Log.d("nearby_connections", "stopAllEndpoints")
                    Nearby.getConnectionsClient(this).stopAllEndpoints()
                    result.success(null)
                }

                "disconnectFromEndpoint" -> {
                    Log.d("nearby_connections", "disconnectFromEndpoint")
                    val endpointId = call.argument<String>("endpointId")
                    assert(endpointId != null)
                    Nearby.getConnectionsClient(this).disconnectFromEndpoint((endpointId)!!)
                    result.success(null)
                }

                "requestConnection" -> {
                    Log.d("nearby_connections", "requestConnection")
                    val userName = call.argument<Any>("userName") as String?
                    val endpointId = call.argument<Any>("endpointId") as String?
                    assert(userName != null)
                    assert(endpointId != null)
                    Nearby.getConnectionsClient(this).requestConnection(
                        (userName)!!,
                        (endpointId)!!,
                        discoveryConnectionLifecycleCallback,
                    ).addOnSuccessListener { result.success(true) }
                        .addOnFailureListener { e -> result.error("Failure", e.message, null) }
                }

                "acceptConnection" -> {
                    val endpointId = call.argument<Any>("endpointId") as String?
                    assert(endpointId != null)
                    Nearby.getConnectionsClient(this)
                        .acceptConnection((endpointId)!!, payloadCallback).addOnSuccessListener {
                            Log.d("nearby_connections", "acceptConnection")
                            result.success(true)
                        }.addOnFailureListener { e ->
                            result.error(
                                "Failure",
                                e.message,
                                null,
                            )
                        }
                }

                "rejectConnection" -> {
                    val endpointId = call.argument<Any>("endpointId") as String?
                    assert(endpointId != null)
                    Nearby.getConnectionsClient(this).rejectConnection((endpointId)!!)
                        .addOnSuccessListener {
                            Log.d("nearby_connections", "rejectConnection")
                            result.success(true)
                        }.addOnFailureListener { e -> result.error("Failure", e.message, null) }
                }

                "sendPayload" -> {
                    val endpointId = call.argument<Any>("endpointId") as String?
                    val rawPayload = call.argument<Any>("payload") as Map<String, Any>
                    val filePath = rawPayload["filePath"] as String?
                    val bytes = rawPayload["bytes"] as ByteArray
                    assert(endpointId != null)
                    assert(
                        (filePath != null) xor (bytes != null),
                    )

                    val payload =
                        try {
                            if (filePath != null) {
                                Payload.fromFile(File(filePath))
                            } else {
                                Payload.fromBytes(bytes!!)
                            }
                        } catch (e: FileNotFoundException) {
                            Log.e("nearby_connections", "File not found", e)
                            result.error("Failure", e.message, null)
                            return
                        }

                    Nearby.getConnectionsClient(this).sendPayload(
                        (endpointId)!!,
                        payload,
                    )
                    Log.d("nearby_connections", "sentPayload")
                    result.success(true)
                }

                "cancelPayload" -> {
                    val payloadId = call.argument<Any>("payloadId") as String?
                    assert(payloadId != null)
                    Nearby.getConnectionsClient(this).cancelPayload(payloadId!!.toLong())
                    Log.d("nearby_connections", "cancelPayload")
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        } catch (e: IllegalArgumentException) {
            result.error("", e.message, null)
        } catch (e: Exception) {
            result.error("", e.message, null)
        }
    }

    private val advertiseConnectionLifecycleCallback: ConnectionLifecycleCallback =
        object : ConnectionLifecycleCallback() {
            override fun onConnectionInitiated(
                endpointId: String,
                connectionInfo: ConnectionInfo,
            ) {
                Log.d("nearby_connections", "onAdvertiseConnectionInitiated")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                args["endpointName"] = connectionInfo.endpointName
                args["authenticationDigits"] = connectionInfo.authenticationDigits
                args["isIncomingConnection"] = connectionInfo.isIncomingConnection
                nearbyChannel.invokeMethod("onAdvertiseConnectionInitiated", args)
            }

            override fun onConnectionResult(
                endpointId: String,
                connectionResolution: ConnectionResolution,
            ) {
                Log.d("nearby_connections", "onAdvertiseConnectionResult")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                var statusCode = -1
                when (connectionResolution.status.statusCode) {
                    ConnectionsStatusCodes.STATUS_OK -> statusCode = 0
                    ConnectionsStatusCodes.STATUS_CONNECTION_REJECTED -> statusCode = 1
                    ConnectionsStatusCodes.STATUS_ERROR -> statusCode = 2
                    else -> {}
                }
                args["statusCode"] = statusCode
                nearbyChannel.invokeMethod("onAdvertiseConnectionResult", args)
            }

            override fun onDisconnected(endpointId: String) {
                Log.d("nearby_connections", "onAdvertiseDisconnected")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                nearbyChannel.invokeMethod("onAdvertiseDisconnected", args)
            }
        }

    private val discoveryConnectionLifecycleCallback: ConnectionLifecycleCallback =
        object : ConnectionLifecycleCallback() {
            override fun onConnectionInitiated(
                endpointId: String,
                connectionInfo: ConnectionInfo,
            ) {
                Log.d("nearby_connections", "onDiscoveryConnectionInitiated")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                args["endpointName"] = connectionInfo.endpointName
                args["authenticationDigits"] = connectionInfo.authenticationDigits
                args["isIncomingConnection"] = connectionInfo.isIncomingConnection
                nearbyChannel.invokeMethod("onDiscoveryConnectionInitiated", args)
            }

            override fun onConnectionResult(
                endpointId: String,
                connectionResolution: ConnectionResolution,
            ) {
                Log.d("nearby_connections", "onDiscoveryConnectionResult")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                var statusCode = -1
                when (connectionResolution.status.statusCode) {
                    ConnectionsStatusCodes.STATUS_OK -> statusCode = 0
                    ConnectionsStatusCodes.STATUS_CONNECTION_REJECTED -> statusCode = 1
                    ConnectionsStatusCodes.STATUS_ERROR -> statusCode = 2
                    else -> {}
                }
                args["statusCode"] = statusCode
                nearbyChannel.invokeMethod("onDiscoveryConnectionResult", args)
            }

            override fun onDisconnected(endpointId: String) {
                Log.d("nearby_connections", "onDiscoveryDisconnected")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                nearbyChannel.invokeMethod("onDiscoveryDisconnected", args)
            }
        }

    private val payloadCallback: PayloadCallback =
        object : PayloadCallback() {
            override fun onPayloadReceived(
                endpointId: String,
                payload: Payload,
            ) {
                Log.d("nearby_connections", "onPayloadReceived")
                val args: MutableMap<String, Any?> = HashMap()
                args["endpointId"] = endpointId
                args["payloadId"] = payload.id
                args["type"] = getPayloadName(payload.type)
                if (payload.type == Payload.Type.BYTES) {
                    val bytes = payload.asBytes()
                    assert(bytes != null)
                    args["bytes"] = bytes
                } else if (payload.type == Payload.Type.FILE) {
                    args["uri"] = payload.asFile()!!.asUri().toString()
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                        // This is deprecated and only available on Android 10 and below.
                        args["filePath"] = payload.asFile()!!.asJavaFile()!!.absolutePath
                    }
                }
                nearbyChannel.invokeMethod("onPayloadReceived", args)
            }

            override fun onPayloadTransferUpdate(
                endpointId: String,
                payloadTransferUpdate: PayloadTransferUpdate,
            ) {
                // required for files and streams
                Log.d("nearby_connections", "onPayloadTransferUpdate")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                args["payloadId"] = payloadTransferUpdate.payloadId
                args["status"] = getTransferStatusName(payloadTransferUpdate.status)
                args["bytesTransferred"] = payloadTransferUpdate.bytesTransferred
                args["totalBytes"] = payloadTransferUpdate.totalBytes
                nearbyChannel.invokeMethod("onPayloadTransferUpdate", args)
            }
        }

    private val endpointDiscoveryCallback: EndpointDiscoveryCallback =
        object : EndpointDiscoveryCallback() {
            override fun onEndpointFound(
                endpointId: String,
                discoveredEndpointInfo: DiscoveredEndpointInfo,
            ) {
                Log.d("nearby_connections", "onEndpointFound")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                args["endpointName"] = discoveredEndpointInfo.endpointName
                args["serviceId"] = discoveredEndpointInfo.serviceId
                nearbyChannel.invokeMethod("onEndpointFound", args)
            }

            override fun onEndpointLost(endpointId: String) {
                Log.d("nearby_connections", "onEndpointLost")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                nearbyChannel.invokeMethod("onEndpointLost", args)
            }
        }

    private fun getStrategy(strategyCode: Int): Strategy {
        return when (strategyCode) {
            0 -> Strategy.P2P_CLUSTER
            1 -> Strategy.P2P_STAR
            2 -> Strategy.P2P_POINT_TO_POINT
            else -> throw IllegalArgumentException()
        }
    }

    private fun getPayloadName(payloadCode: Int): String {
        return when (payloadCode) {
            1 -> "bytes"
            2 -> "file"
            3 -> "stream"
            else -> throw IllegalArgumentException()
        }
    }

    private fun getTransferStatusName(transferUpdateCode: Int): String {
        return when (transferUpdateCode) {
            1 -> "success"
            2 -> "failure"
            3 -> "inProgress"
            4 -> "canceled"
            else -> throw IllegalArgumentException()
        }
    }
}

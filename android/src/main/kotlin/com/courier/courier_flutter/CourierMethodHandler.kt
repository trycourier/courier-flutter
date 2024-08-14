package com.courier.courier_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

internal abstract class CourierMethodHandler(channel: CourierFlutterChannel, binding: FlutterPlugin.FlutterPluginBinding) : MethodCallHandler {

    private val methodChannel = channel.getChannel(binding.binaryMessenger)

    fun attach() = methodChannel.setMethodCallHandler(this)
    fun detach() = methodChannel.setMethodCallHandler(null)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.Main).launch {
            handleMethod(call, result)
        }
    }

    open suspend fun handleMethod(call: MethodCall, result: MethodChannel.Result) {
        // Empty
    }

}
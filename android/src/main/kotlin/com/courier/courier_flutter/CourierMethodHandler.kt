package com.courier.courier_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

internal abstract class CourierMethodHandler(channel: CourierFlutterChannel, binding: FlutterPlugin.FlutterPluginBinding) : MethodCallHandler {

    private val methodChannel: MethodChannel = MethodChannel(binding.binaryMessenger, channel.id)

    fun attach() = methodChannel.setMethodCallHandler(this)

}
package com.courier.courier_flutter
import com.courier.android.Courier
import com.courier.android.models.CourierAgent
import io.flutter.embedding.engine.plugins.FlutterPlugin

internal class CourierPlugin : FlutterPlugin {

    private var clientMethodHandler: ClientMethodHandler? = null
    private var sharedMethodHandler: SharedMethodHandler? = null

    companion object {
        internal const val TAG = "Courier Android SDK Error"
    }

    init {
        Courier.agent = CourierAgent.FlutterAndroid(version = "4.1.1")
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

        clientMethodHandler = ClientMethodHandler(
            channel = CourierFlutterChannel.CLIENT,
            binding = flutterPluginBinding
        ).apply {
            attach()
        }

        sharedMethodHandler = SharedMethodHandler(
           channel = CourierFlutterChannel.SHARED,
           binding = flutterPluginBinding
        ).apply {
            attach()
        }

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        clientMethodHandler?.detach()
        sharedMethodHandler?.detach()
    }

}

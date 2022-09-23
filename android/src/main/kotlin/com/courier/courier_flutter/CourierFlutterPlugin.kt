package com.courier.courier_flutter

import androidx.annotation.NonNull
import com.courier.android.Courier

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** CourierFlutterPlugin */
class CourierFlutterPlugin: FlutterPlugin, MethodCallHandler {

  companion object {
    private const val COURIER_ERROR_TAG = "Courier Android SDK Error"
  }

  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "courier_flutter")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

    when (call.method) {

      "userId" -> {

        val userId = Courier.shared.userId
        result.success(userId)

      }

      "signIn" -> {

        val params = call.arguments as HashMap<*, *>
        val accessToken = params["accessToken"] as? String
        val userId = params["userId"] as? String

        Courier.shared.signIn(
          accessToken = accessToken ?: "",
          userId = userId ?: "",
          onSuccess = {
            result.success(null)
          },
          onFailure = { error ->
            result.error(COURIER_ERROR_TAG, error.message, error)
          }
        )

      }

      "signOut" -> {

        Courier.shared.signOut(
          onSuccess = {
            result.success(null)
          },
          onFailure = { error ->
            result.error(COURIER_ERROR_TAG, error.message, error)
          }
        )

      }

      else -> {
        result.notImplemented()
      }

    }

  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

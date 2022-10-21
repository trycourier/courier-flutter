package com.courier.courier_flutter

import android.util.Log
import com.courier.android.BuildConfig
import com.courier.android.Courier
import com.courier.android.models.CourierAgent
import com.courier.android.models.CourierProvider
import com.courier.android.sendPush

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** CourierFlutterPlugin */
class CourierFlutterPlugin: FlutterPlugin, MethodCallHandler {

  companion object {
    private const val COURIER_ERROR_TAG = "Courier Android SDK Error"
    internal const val CORE_CHANNEL = "courier_flutter_core"
    internal const val EVENTS_CHANNEL = "courier_flutter_events"
  }

  init {
    Courier.USER_AGENT = CourierAgent.FLUTTER_ANDROID
  }

  private var channel: MethodChannel? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CORE_CHANNEL).apply {
      setMethodCallHandler(this@CourierFlutterPlugin)
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    when (call.method) {

      "isDebugging" -> {

        val params = call.arguments as HashMap<*, *>
        val isDebugging = params["isDebugging"] as? Boolean
        Courier.shared.isDebugging = isDebugging ?: BuildConfig.DEBUG
        result.success(isDebugging)

      }

      "userId" -> {

        val userId = Courier.shared.userId
        result.success(userId)

      }

      "fcmToken" -> {

        val fcmToken = Courier.shared.fcmToken
        result.success(fcmToken)

      }

      "setFcmToken" -> {

        val params = call.arguments as HashMap<*, *>
        val token = params["token"] as? String

        Courier.shared.setFCMToken(
          token = token ?: "",
          onSuccess = {
            result.success(null)
          },
          onFailure = { error ->
            result.error(COURIER_ERROR_TAG, error.message, error)
          })

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

      "sendPush" -> {

        val params = call.arguments as HashMap<*, *>
        val authKey = params["authKey"] as? String
        val userId = params["userId"] as? String
        val title = params["title"] as? String
        val body = params["body"] as? String
        val isProduction = params["isProduction"] as? Boolean
        val providers = params["providers"] as? List<*>

        // Map the providers to the proper enums
        val courierProviders = providers?.mapNotNull { value ->
          return@mapNotNull CourierProvider.values().firstOrNull { provider ->
            provider.value == value.toString()
          }
        }.orEmpty()

        Courier.shared.sendPush(
          authKey = authKey ?: "",
          userId = userId ?: "",
          title = title ?: "",
          body = body ?: "",
          isProduction = isProduction ?: false,
          providers = courierProviders,
          onSuccess = { requestId ->
            result.success(requestId)
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

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
  }

}

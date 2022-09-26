package com.courier.courier_flutter

import android.content.Intent
import android.os.Bundle
import com.courier.android.Courier
import com.courier.android.trackPushNotificationClick
import com.google.firebase.messaging.RemoteMessage
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

open class CourierFlutterActivity : FlutterActivity() {

    private var eventChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        eventChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "courier_flutter_events")
        eventChannel?.setMethodCallHandler { call, result ->
            when (call.method) {

                "getClickedNotification" -> {
                    checkIntentForPushNotificationClick(intent)
                    result.success(null)
                }

                else -> {
                    result.notImplemented()
                }

            }
        }
    }

    override fun detachFromFlutterEngine() {
        super.detachFromFlutterEngine()
        eventChannel?.setMethodCallHandler(null)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Courier.initialize(this)

        // See if there is a pending click event
        checkIntentForPushNotificationClick(intent)

        // Handle delivered messages on the main thread
        Courier.getLastDeliveredMessage { message ->
            postPushNotificationDelivered(message)
        }

    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        checkIntentForPushNotificationClick(intent)
    }

    private fun checkIntentForPushNotificationClick(intent: Intent?) {
        intent?.trackPushNotificationClick { message ->
            postPushNotificationClicked(message)
        }
    }

    private fun postPushNotificationDelivered(message: RemoteMessage) {
        eventChannel?.invokeMethod("pushNotificationDelivered", message.data)
    }

    private fun postPushNotificationClicked(message: RemoteMessage) {
        eventChannel?.invokeMethod("pushNotificationClicked", message.data)
    }

}
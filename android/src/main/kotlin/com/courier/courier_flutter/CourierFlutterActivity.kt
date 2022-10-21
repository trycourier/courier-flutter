package com.courier.courier_flutter

import android.content.Intent
import android.os.Bundle
import com.courier.android.Courier
import com.courier.android.pushNotification
import com.courier.android.trackPushNotificationClick
import com.google.firebase.messaging.RemoteMessage
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


open class CourierFlutterActivity : FlutterActivity() {

    private var eventsChannel: MethodChannel? = null

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        eventsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CourierFlutterPlugin.EVENTS_CHANNEL).apply {
            setMethodCallHandler { call, result ->

                when (call.method) {

                    "requestNotificationPermission" -> {

                        // TODO: Not supported yet due to AppCompat issues
                        result.success("unknown")

                    }

                    "getNotificationPermissionStatus" -> {

                        // TODO: Not supported yet due to AppCompat issues
                        result.success("unknown")

                    }

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

    }

    override fun detachFromFlutterEngine() {
        super.detachFromFlutterEngine()
        eventsChannel?.setMethodCallHandler(null)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize the SDK
        Courier.initialize(context = this)

        // Set the events listener
        Courier.shared.logListener = { log ->
            runOnUiThread {
                eventsChannel?.invokeMethod("log", log)
            }
        }

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
        eventsChannel?.invokeMethod("pushNotificationDelivered", message.pushNotification)
    }

    private fun postPushNotificationClicked(message: RemoteMessage) {
        eventsChannel?.invokeMethod("pushNotificationClicked", message.pushNotification)
    }

}
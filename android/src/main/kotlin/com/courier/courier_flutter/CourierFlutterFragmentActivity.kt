package com.courier.courier_flutter

import android.content.Intent
import android.os.Bundle
import com.courier.android.Courier
import com.courier.android.modules.logListener
import com.courier.android.utils.getLastDeliveredMessage
import com.google.firebase.messaging.RemoteMessage
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


open class CourierFlutterFragmentActivity : FlutterFragmentActivity(), CourierFlutterPushNotificationListener {

    private var eventsChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup all the supported channels Courier can use
        eventsChannel = flutterEngine.setupCourierMethodChannel(
            onGetClickedNotification = {
                intent.getAndTrackRemoteMessage()?.let { message ->
                    postPushNotificationClicked(message)
                }
            }
        )

    }

    override fun onDestroy() {
        super.onDestroy()

        // Remove the callbacks
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
        intent.getAndTrackRemoteMessage()?.let { message ->
            postPushNotificationClicked(message)
        }

        // Handle delivered messages on the main thread
        Courier.shared.getLastDeliveredMessage { message ->
            postPushNotificationDelivered(message)
        }

    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        intent.getAndTrackRemoteMessage()?.let { message ->
            postPushNotificationClicked(message)
        }

    }

    override fun postPushNotificationDelivered(message: RemoteMessage) {
        eventsChannel?.deliverCourierPushNotification(message)
    }

    override fun postPushNotificationClicked(message: RemoteMessage) {
        eventsChannel?.clickCourierPushNotification(message)
    }

}
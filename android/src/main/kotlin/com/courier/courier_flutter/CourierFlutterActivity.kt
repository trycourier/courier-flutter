package com.courier.courier_flutter

import android.content.Intent
import android.os.Bundle
import com.courier.android.Courier
import com.courier.android.trackPushNotificationClick
import io.flutter.embedding.android.FlutterActivity

open class CourierFlutterActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Courier.initialize(this)

        // See if there is a pending click event
        checkIntentForPushNotificationClick(intent)

        // Handle delivered messages on the main thread
        Courier.getLastDeliveredMessage { message ->
            print("YAY")
//            pushNotificationCallbacks?.onPushNotificationDelivered(message)
        }

    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        checkIntentForPushNotificationClick(intent)
    }

    private fun checkIntentForPushNotificationClick(intent: Intent?) {
        intent?.trackPushNotificationClick { message ->
            print("YAY")
//            pushNotificationCallbacks?.onPushNotificationClicked(message)
        }
    }

}
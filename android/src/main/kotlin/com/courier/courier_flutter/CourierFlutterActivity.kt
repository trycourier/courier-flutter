package com.courier.courier_flutter

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.courier.android.Courier
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

//                        ActivityCompat.requestPermissions(this, new String[] {Manifest.permission.READ_CONTACTS}, 0);

//                        ActivityCompat.requestPermissions(this@CourierFlutterActivity, new String[] {Manifest.permission.READ_CONTACTS}, 0)

//                        ContextCompat.checkSelfPermission(this@CourierFlutterActivity, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED -> {
//                            // You can use the API that requires the permission.
//                        }
//
//                        requestPermissionLauncher.launch(
//                            Manifest.permission.REQUESTED_PERMISSION)

                        if (Build.VERSION.SDK_INT >= 33) {
                            val isGranted = ContextCompat.checkSelfPermission(this@CourierFlutterActivity, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
                            ActivityCompat.requestPermissions(this@CourierFlutterActivity, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 222)
//                            result.success(isGranted.toString())
                        } else {
                            result.success("not_ready")
                        }

//                        if (ContextCompat.checkSelfPermission(this@CourierFlutterActivity, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
//
//                            val test = 123
//
//                            if (Build.VERSION.SDK_INT >= 33) {
//                                ActivityCompat.requestPermissions(this@CourierFlutterActivity, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 123)
//                            }
//
//                        } else {
//                            print("asdasd")
//                        }

//                        if (Build.VERSION.SDK_INT >= 33) {
//                            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 123)
//                        } else {
//                            val test = 123
//                        }

//                        when {
//                            ContextCompat.checkSelfPermission(this@CourierFlutterActivity, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED -> {
//                                // You can use the API that requires the permission.
//                            }
//                        }
//                            else -> {
//                                // You can directly ask for the permission.
//                                // The registered ActivityResultCallback gets the result of this request.
//                                requestPermissionLauncher.launch(
//                                    Manifest.permission.REQUESTED_PERMISSION)
//                            }
//                        }

//                        result.success("something")

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
        eventsChannel?.invokeMethod("pushNotificationDelivered", message.data)
    }

    private fun postPushNotificationClicked(message: RemoteMessage) {
        eventsChannel?.invokeMethod("pushNotificationClicked", message.data)
    }

}
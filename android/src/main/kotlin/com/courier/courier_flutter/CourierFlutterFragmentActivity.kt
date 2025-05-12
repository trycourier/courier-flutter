package com.courier.courier_flutter

import android.content.Intent
import android.os.Bundle
import com.courier.android.Courier
import com.courier.android.models.CourierAgent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

open class CourierFlutterFragmentActivity : FlutterFragmentActivity() {

    private val handler = CourierSystemEventHandler()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        handler.configure(flutterEngine, this)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handler.attach(this, intent)

        // Setup and run the agent
        Courier.agent = CourierAgent.FlutterAndroid(version = "4.1.1")
        Courier.initialize(this)

    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handler.newIntent(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.detach()
    }

}
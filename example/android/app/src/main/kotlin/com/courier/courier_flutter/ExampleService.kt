package com.courier.courier_flutter

import android.annotation.SuppressLint
import com.courier.android.notifications.presentNotification
import com.courier.android.service.CourierService
import com.google.firebase.messaging.RemoteMessage

// Warning is suppressed
// You do not need to worry about this warning
// The CourierService will handle the function automatically
@SuppressLint("MissingFirebaseInstanceTokenRefresh")
class ExampleService: CourierService() {

    override fun showNotification(message: RemoteMessage) {
        super.showNotification(message)

        // TODO: This is where you will customize the notification that is shown to your users
        // The function below is used to get started quickly.
        // You likely do not want to use `message.presentNotification(...)`
        // Make sure you point the handling class back to MainActivity
        // For details on how to customize an Android notification, check here:
        // https://developer.android.com/develop/ui/views/notifications/build-notification

        message.presentNotification(
            context = this,
            handlingClass = MainActivity::class.java
        )

    }

}
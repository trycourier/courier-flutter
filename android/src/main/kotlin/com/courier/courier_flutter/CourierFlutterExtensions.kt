package com.courier.courier_flutter

import android.content.Intent
import com.courier.android.models.CourierBrand
import com.courier.android.models.CourierBrandColors
import com.courier.android.models.CourierBrandInApp
import com.courier.android.models.CourierBrandSettings
import com.courier.android.models.CourierPreferenceTopic
import com.courier.android.models.CourierUserPreferences
import com.courier.android.models.InboxAction
import com.courier.android.models.InboxMessage
import com.courier.android.models.Paging
import com.courier.android.utils.trackPushNotificationClick
import com.google.firebase.messaging.RemoteMessage

fun Intent.getAndTrackRemoteMessage(): RemoteMessage? {

    var clickedMessage: RemoteMessage? = null

    // Try and track the clicked message
    // Will return a message if the message was able to be tracked
    trackPushNotificationClick { message ->
        clickedMessage = message
    }

    return clickedMessage

}

internal fun InboxMessage.toMap(): Map<String, Any?> {
    return mapOf(
        "messageId" to messageId,
        "title" to title,
        "body" to body,
        "preview" to preview,
        "created" to created,
        "actions" to actions?.map { it.toMap() },
        "data" to data,
        "read" to read,
        "opened" to opened,
        "archived" to archived,
    )
}

internal fun InboxAction.toMap(): Map<String, Any?> {
    return mapOf(
        "content" to content,
        "href" to href,
        "data" to data
    )
}

internal fun CourierBrand.toMap(): Map<String, Any?> {
    return mapOf(
        "settings" to settings?.toMap(),
    )
}

internal fun CourierBrandSettings.toMap(): Map<String, Any?> {
    return mapOf(
        "colors" to colors?.toMap(),
        "inapp" to inapp?.toMap(),
    )
}

internal fun CourierBrandInApp.toMap(): Map<String, Any?> {
    return mapOf(
        "showCourierFooter" to showCourierFooter,
    )
}

internal fun CourierBrandColors.toMap(): Map<String, Any?> {
    return mapOf(
        "primary" to primary,
    )
}

internal fun CourierUserPreferences.toMap(): Map<String, Any?> {
    return mapOf(
        "items" to items.map { it.toMap() },
        "paging" to paging.toMap(),
    )
}

internal fun CourierPreferenceTopic.toMap(): Map<String, Any?> {
    return mapOf(
        "defaultStatus" to defaultStatus.value,
        "hasCustomRouting" to hasCustomRouting,
        "status" to status.value,
        "topicId" to topicId,
        "topicName" to topicName,
        "sectionName" to sectionName,
        "sectionId" to sectionId,
        "customRouting" to customRouting.map { it.value }
    )
}

internal fun Paging.toMap(): Map<String, Any?>{
    return mapOf(
        "cursor" to cursor,
        "more" to more,
    )
}
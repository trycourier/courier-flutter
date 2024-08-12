package com.courier.courier_flutter

import com.courier.android.Courier
import com.courier.android.models.CourierDevice
import com.courier.android.models.CourierPreferenceChannel
import com.courier.android.models.CourierPreferenceStatus
import com.courier.android.models.CourierTrackingEvent
import com.courier.android.modules.inboxPaginationLimit
import com.courier.courier_flutter.CourierPlugin.Companion.TAG
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class ClientMethodHandler(channel: CourierFlutterChannel, private val binding: FlutterPlugin.FlutterPluginBinding) : CourierMethodHandler(channel, binding) {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) = post {

        try {

            val params = call.arguments as? HashMap<*, *>

            val client = params?.toClient() ?: throw MissingParameter("client")

            when (call.method) {

                // == Brand ==

                "brands.get_brand" -> {

                    val (brandId) = listOf<String>(
                        params.extract("brandId"),
                    )

                    val brand = client.brands.getBrand(brandId)
                    val json = brand.toJson()
                    result.success(json)

                }

                // == Token Management ==

                "tokens.put_user_token" -> {

                    val (token, provider) = listOf<String>(
                        params.extract("token"),
                        params.extract("provider"),
                    )

                    val deviceParams = params["device"] as? Map<*, *>
                    val device = deviceParams?.toCourierDevice()

                    client.tokens.putUserToken(
                        token = token,
                        provider = provider,
                        device = device ?: CourierDevice.current(binding.applicationContext),
                    )

                    result.success(null)

                }

                "tokens.delete_user_token" -> {

                    val (token) = listOf<String>(
                        params.extract("token"),
                    )

                    client.tokens.deleteUserToken(
                        token = token,
                    )

                    result.success(null)

                }

                // == Inbox ==

                "inbox.get_messages" -> {

                    val paginationLimit = params["paginationLimit"] as? Int
                    val startCursor = params["startCursor"] as? String

                    val res = client.inbox.getMessages(
                        paginationLimit = paginationLimit ?: Courier.shared.inboxPaginationLimit,
                        startCursor = startCursor
                    )

                    val json = res.toJson()
                    result.success(json)

                }

                "inbox.get_archived_messages" -> {

                    val paginationLimit = params["paginationLimit"] as? Int
                    val startCursor = params["startCursor"] as? String

                    val res = client.inbox.getArchivedMessages(
                        paginationLimit = paginationLimit ?: Courier.shared.inboxPaginationLimit,
                        startCursor = startCursor
                    )

                    val json = res.toJson()
                    result.success(json)

                }

                "inbox.get_unread_message_count" -> {

                    val count = client.inbox.getUnreadMessageCount()
                    result.success(count)

                }

                "inbox.get_message_by_id" -> {

                    val (messageId) = listOf<String>(
                        params.extract("messageId"),
                    )

                    val res = client.inbox.getMessage(
                        messageId = messageId
                    )

                    val json = res.toJson()
                    result.success(json)

                }

                "inbox.click_message" -> {

                    val (messageId, trackingId) = listOf<String>(
                        params.extract("messageId"),
                        params.extract("trackingId"),
                    )

                    client.inbox.click(
                        messageId = messageId,
                        trackingId = trackingId
                    )

                    result.success(null)

                }

                "inbox.unread_message" -> {

                    val (messageId) = listOf<String>(
                        params.extract("messageId"),
                    )

                    client.inbox.unread(
                        messageId = messageId,
                    )

                    result.success(null)

                }

                "inbox.read_message" -> {

                    val (messageId) = listOf<String>(
                        params.extract("messageId"),
                    )

                    client.inbox.read(
                        messageId = messageId,
                    )

                    result.success(null)

                }

                "inbox.open_message" -> {

                    val (messageId) = listOf<String>(
                        params.extract("messageId"),
                    )

                    client.inbox.open(
                        messageId = messageId,
                    )

                    result.success(null)

                }

                "inbox.archive_message" -> {

                    val (messageId) = listOf<String>(
                        params.extract("messageId"),
                    )

                    client.inbox.archive(
                        messageId = messageId,
                    )

                    result.success(null)

                }

                "inbox.read_all_messages" -> {

                    client.inbox.readAll()

                    result.success(null)

                }

                // == Preferences ==

                "preferences.get_user_preferences" -> {

                    val paginationCursor = params["paginationCursor"] as? String

                    val res = client.preferences.getUserPreferences(
                        paginationCursor = paginationCursor
                    )

                    val json = res.toJson()
                    result.success(json)

                }

                "preferences.get_user_preference_topic" -> {

                    val (topicId) = listOf<String>(
                        params.extract("topicId"),
                    )

                    val res = client.preferences.getUserPreferenceTopic(
                        topicId = topicId
                    )

                    val json = res.toJson()
                    result.success(json)

                }

                "preferences.put_user_preference_topic" -> {

                    val topicId = params.extract<String>("topicId")
                    val status = params.extract<String>("status")
                    val hasCustomRouting = params.extract<Boolean>("hasCustomRouting")
                    val customRouting = params.extract<List<String>>("customRouting")

                    client.preferences.putUserPreferenceTopic(
                        topicId = topicId,
                        status = CourierPreferenceStatus.valueOf(status),
                        hasCustomRouting = hasCustomRouting,
                        customRouting = customRouting.map { CourierPreferenceChannel.fromString(it) },
                    )

                    result.success(null)

                }

                // == Tracking ==

                "tracking.post_tracking_url" -> {

                    val (url, event) = listOf<String>(
                        params.extract("url"),
                        params.extract("event"),
                    )

                    client.tracking.postTrackingUrl(
                        url = url,
                        event = CourierTrackingEvent.valueOf(event)
                    )

                    result.success(null)

                }

                else -> {
                    result.notImplemented()
                }

            }

        } catch (e: Exception) {

            result.error(TAG, e.message, e)

        }

    }

}
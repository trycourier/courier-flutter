package com.courier.courier_flutter

import com.courier.android.Courier
import com.courier.android.models.CourierAuthenticationListener
import com.courier.android.models.CourierInboxListener
import com.courier.android.models.remove
import com.courier.android.modules.addAuthenticationListener
import com.courier.android.modules.addInboxListener
import com.courier.android.modules.archiveMessage
import com.courier.android.modules.archivedMessages
import com.courier.android.modules.clickMessage
import com.courier.android.modules.fcmToken
import com.courier.android.modules.feedMessages
import com.courier.android.modules.fetchNextInboxPage
import com.courier.android.modules.getToken
import com.courier.android.modules.inboxPaginationLimit
import com.courier.android.modules.isUserSignedIn
import com.courier.android.modules.openMessage
import com.courier.android.modules.readAllInboxMessages
import com.courier.android.modules.readMessage
import com.courier.android.modules.refreshInbox
import com.courier.android.modules.removeAllInboxListeners
import com.courier.android.modules.removeAuthenticationListener
import com.courier.android.modules.removeInboxListener
import com.courier.android.modules.setToken
import com.courier.android.modules.signIn
import com.courier.android.modules.signOut
import com.courier.android.modules.tenantId
import com.courier.android.modules.tokens
import com.courier.android.modules.unreadMessage
import com.courier.android.modules.userId
import com.courier.android.ui.inbox.InboxMessageFeed
import com.courier.courier_flutter.CourierPlugin.Companion.TAG
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class SharedMethodHandler(channel: CourierFlutterChannel, private val binding: FlutterPlugin.FlutterPluginBinding) : CourierMethodHandler(channel, binding) {

    private var authenticationListeners = mutableMapOf<String, CourierAuthenticationListener>()
    private var inboxListeners = mutableMapOf<String, CourierInboxListener>()

    override suspend fun handleMethod(call: MethodCall, result: MethodChannel.Result) {

        try {

            when (call.method) {

                // == Client ==

                "client.get_options" -> {

                    val options = Courier.shared.client?.options

                    if (options == null) {
                        result.success(null)
                        return
                    }

                    val client = mapOf(
                        "jwt" to options.jwt,
                        "clientKey" to options.clientKey,
                        "userId" to options.userId,
                        "connectionId" to options.connectionId,
                        "tenantId" to options.tenantId,
                        "showLogs" to options.showLogs
                    )

                    result.success(client)

                }

                // == Authentication ==

                "auth.user_id" -> {

                    result.success(Courier.shared.userId)

                }

                "auth.tenant_id" -> {

                    result.success(Courier.shared.tenantId)

                }

                "auth.is_user_signed_in" -> {

                    result.success(Courier.shared.isUserSignedIn)

                }

                "auth.sign_in" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val userId = params.extract("userId") as String
                    val tenantId = params["tenantId"] as? String
                    val accessToken = params.extract("accessToken") as String
                    val clientKey = params["clientKey"] as? String
                    val showLogs = params.extract("showLogs") as Boolean

                    Courier.shared.signIn(
                        userId = userId,
                        tenantId = tenantId,
                        accessToken = accessToken,
                        clientKey = clientKey,
                        showLogs = showLogs,
                    )

                    result.success(null)

                }

                "auth.sign_out" -> {

                    Courier.shared.signOut()

                    result.success(null)

                }

                "auth.add_authentication_listener" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val listenerId = params.extract("listenerId") as String

                    // Create the listener
                    val listener = Courier.shared.addAuthenticationListener { userId ->
                        CourierFlutterChannel.EVENTS.invokeMethod(binding.binaryMessenger, method = "auth.state_changed", mapOf(
                            "userId" to userId,
                            "id" to listenerId
                        ))
                    }

                    // Hold reference to the auth listeners
                    authenticationListeners[listenerId] = listener

                    result.success(listenerId)

                }

                "auth.remove_authentication_listener" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val listenerId = params.extract("listenerId") as String

                    // Get and remove the listener
                    val listener = authenticationListeners[listenerId] ?: throw InvalidParameter("listenerId")
                    listener.remove()

                    result.success(null)

                }

                "auth.remove_all_authentication_listeners" -> {

                    for (value in authenticationListeners.values) {
                        Courier.shared.removeAuthenticationListener(value)
                    }

                    authenticationListeners.clear()

                    result.success(null)

                }

                // == Push ==

                "tokens.get_fcm_token" -> {

                    val fcmToken = Courier.shared.fcmToken

                    result.success(fcmToken)

                }

                "tokens.get_all_tokens" -> {

                    val tokens = Courier.shared.tokens

                    result.success(tokens)

                }

                "tokens.set_token" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val token = params.extract("token") as String
                    val provider = params.extract("provider") as String

                    Courier.shared.setToken(
                        provider = provider,
                        token = token,
                    )

                    result.success(null)

                }

                "tokens.get_token" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val provider = params.extract("provider") as String

                    val token = Courier.shared.getToken(
                        provider = provider,
                    )

                    result.success(token)

                }

                // == Inbox ==

                "inbox.get_pagination_limit" -> {

                    val limit = Courier.shared.inboxPaginationLimit

                    result.success(limit)

                }

                "inbox.set_pagination_limit" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val limit = params.extract("limit") as Int

                    Courier.shared.inboxPaginationLimit = limit

                    result.success(null)

                }

                "inbox.get_feed_messages" -> {

                    val messages = Courier.shared.feedMessages

                    val json = messages.map { it.toJson() }

                    result.success(json)

                }

                "inbox.get_archived_messages" -> {

                    val messages = Courier.shared.archivedMessages

                    val json = messages.map { it.toJson() }

                    result.success(json)

                }

                "inbox.refresh" -> {

                    Courier.shared.refreshInbox()

                    result.success(null)

                }

                "inbox.fetch_next_page" -> {
                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val feedParam = params.extract("feed") as String  // "archive" or "feed"
                    val inboxFeed = if (feedParam == "archive") { InboxMessageFeed.ARCHIVE } else { InboxMessageFeed.FEED }

                    val messageSet = Courier.shared.fetchNextInboxPage(inboxFeed)

                    val messagesJson = messageSet
                        ?.messages
                        ?.map { it.toJson() }
                        ?: emptyList()

                    val resultMap = mapOf(
                        "messages" to messagesJson,
                        "totalCount" to (messageSet?.totalCount ?: 0),
                        "canPaginate" to (messageSet?.canPaginate ?: false),
                        "paginationCursor" to (messageSet?.paginationCursor ?: "")
                    )

                    result.success(resultMap)
                }

                "inbox.add_listener" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val listenerId = params.extract("listenerId") as String

                    val listener = Courier.shared.addInboxListener(
                        onLoading = {
                            CourierFlutterChannel.EVENTS.invokeMethod(
                                messenger = binding.binaryMessenger,
                                method = "auth.state_changed",
                                arguments = mapOf(
                                    "id" to listenerId
                                )
                            )
                        },
                        onError = { error ->
                            CourierFlutterChannel.EVENTS.invokeMethod(
                                messenger = binding.binaryMessenger,
                                method = "inbox.listener_error",
                                arguments = mapOf(
                                    "id" to listenerId,
                                    "error" to error.message
                                )
                            )
                        },
                        onUnreadCountChanged = { count ->
                            CourierFlutterChannel.EVENTS.invokeMethod(
                                messenger = binding.binaryMessenger,
                                method = "inbox.listener_unread_count_changed",
                                arguments = mapOf(
                                    "id" to listenerId,
                                    "count" to count
                                )
                            )
                        },
                        onTotalCountChanged = { totalCount, feed ->
                            val feedName = if (feed == InboxMessageFeed.ARCHIVE) "archive" else "feed"
                            CourierFlutterChannel.EVENTS.invokeMethod(
                                messenger = binding.binaryMessenger,
                                method = "inbox.listener_total_count_changed",
                                arguments = mapOf(
                                    "id" to listenerId,
                                    "feed" to feedName,
                                    "totalCount" to totalCount
                                )
                            )
                        },
                        onMessagesChanged = { messages, canPaginate, feed ->
                            val feedName = if (feed == InboxMessageFeed.ARCHIVE) "archive" else "feed"
                            try {
                                val jsonMessages = messages.map { it.toJson() }
                                CourierFlutterChannel.EVENTS.invokeMethod(
                                    messenger = binding.binaryMessenger,
                                    method = "inbox.listener_messages_changed",
                                    arguments = mapOf(
                                        "id" to listenerId,
                                        "feed" to feedName,
                                        "canPaginate" to canPaginate,
                                        "messages" to jsonMessages
                                    )
                                )
                            } catch (e: Exception) {
                                e.printStackTrace()
                            }
                        },
                        onPageAdded = { messages, canPaginate, isFirstPage, feed ->
                            val feedName = if (feed == InboxMessageFeed.ARCHIVE) "archive" else "feed"
                            try {
                                val jsonMessages = messages.map { it.toJson() }
                                CourierFlutterChannel.EVENTS.invokeMethod(
                                    messenger = binding.binaryMessenger,
                                    method = "inbox.listener_page_added",
                                    arguments = mapOf(
                                        "id" to listenerId,
                                        "feed" to feedName,
                                        "canPaginate" to canPaginate,
                                        "isFirstPage" to isFirstPage,
                                        "messages" to jsonMessages
                                    )
                                )
                            } catch (e: Exception) {
                                e.printStackTrace()
                            }
                        },
                        onMessageEvent = { message, index, feed, event ->
                            val feedName = if (feed == InboxMessageFeed.ARCHIVE) "archive" else "feed"
                            try {
                                val messageJson = message.toJson()
                                val eventName = event.name.lowercase() // e.g., "added", "changed", "removed"
                                CourierFlutterChannel.EVENTS.invokeMethod(
                                    messenger = binding.binaryMessenger,
                                    method = "inbox.listener_message_event",
                                    arguments = mapOf(
                                        "id" to listenerId,
                                        "feed" to feedName,
                                        "event" to eventName,
                                        "index" to index,
                                        "message" to messageJson
                                    )
                                )
                            } catch (e: Exception) {
                                e.printStackTrace()
                            }
                        }
                    )

                    inboxListeners[listenerId] = listener

                    result.success(listenerId)

                }

                "inbox.remove_listener" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val listenerId = params.extract("listenerId") as String

                    // Get and remove the listener
                    val listener = inboxListeners[listenerId] ?: throw InvalidParameter("listenerId")
                    Courier.shared.removeInboxListener(listener)

                    result.success(null)

                }

                "inbox.remove_all_listeners" -> {

                    Courier.shared.removeAllInboxListeners()

                    inboxListeners.clear()

                    result.success(null)

                }

                "inbox.open_message" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val messageId = params.extract("messageId") as String

                    Courier.shared.openMessage(messageId)

                    result.success(null)

                }

                "inbox.read_message" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val messageId = params.extract("messageId") as String

                    Courier.shared.readMessage(messageId)

                    result.success(null)

                }

                "inbox.unread_message" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val messageId = params.extract("messageId") as String

                    Courier.shared.unreadMessage(messageId)

                    result.success(null)

                }

                "inbox.click_message" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val messageId = params.extract("messageId") as String

                    Courier.shared.clickMessage(messageId)

                    result.success(null)

                }

                "inbox.archive_message" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val messageId = params.extract("messageId") as String

                    Courier.shared.archiveMessage(messageId)

                    result.success(null)

                }

                "inbox.read_all_messages" -> {

                    Courier.shared.readAllInboxMessages()

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
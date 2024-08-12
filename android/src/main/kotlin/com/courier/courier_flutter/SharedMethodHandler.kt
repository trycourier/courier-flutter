package com.courier.courier_flutter

import com.courier.android.Courier
import com.courier.android.models.CourierAuthenticationListener
import com.courier.android.models.CourierInboxListener
import com.courier.android.models.remove
import com.courier.android.modules.addAuthenticationListener
import com.courier.android.modules.addInboxListener
import com.courier.android.modules.archiveMessage
import com.courier.android.modules.clickMessage
import com.courier.android.modules.fcmToken
import com.courier.android.modules.fetchNextInboxPage
import com.courier.android.modules.getToken
import com.courier.android.modules.inboxPaginationLimit
import com.courier.android.modules.isUserSignedIn
import com.courier.android.modules.openMessage
import com.courier.android.modules.readAllInboxMessages
import com.courier.android.modules.readMessage
import com.courier.android.modules.refreshInbox
import com.courier.android.modules.setToken
import com.courier.android.modules.signIn
import com.courier.android.modules.signOut
import com.courier.android.modules.tenantId
import com.courier.android.modules.tokens
import com.courier.android.modules.unreadMessage
import com.courier.android.modules.userId
import com.courier.courier_flutter.CourierPlugin.Companion.TAG
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class SharedMethodHandler(channel: CourierFlutterChannel, private val binding: FlutterPlugin.FlutterPluginBinding) : CourierMethodHandler(channel, binding) {

    private var authenticationListeners = mutableMapOf<String, CourierAuthenticationListener>()
    private var inboxListeners = mutableMapOf<String, CourierInboxListener>()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) = post {

        try {

            when (call.method) {

                // == Client ==

                "client.get_options" -> {

                    val options = Courier.shared.client?.options

                    if (options == null) {
                        result.success(null)
                        return@post
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
                        CourierFlutterChannel.EVENTS.getChannel(binding.binaryMessenger).invokeMethod("auth.state_changed", mapOf(
                            "userId" to userId
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
                        value.remove()
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

                "inbox.get_messages" -> {

                    val messages = Courier.shared.inboxMessages ?: emptyList()

                    val json = messages.map { it.toJson() }

                    result.success(json)

                }

                "inbox.refresh" -> {

                    Courier.shared.refreshInbox()

                    result.success(null)

                }

                "inbox.fetch_next_page" -> {

                    val messages = Courier.shared.fetchNextInboxPage()

                    val json = messages.map { it.toJson() }

                    result.success(json)

                }

                "inbox.add_listener" -> {

                    val params = call.arguments as? HashMap<*, *> ?: throw MissingParameter("params")

                    val listenerId = params.extract("listenerId") as String

                    val channel = CourierFlutterChannel.EVENTS.getChannel(binding.binaryMessenger)

                    val listener = Courier.shared.addInboxListener(
                        onInitialLoad = {
                            channel.invokeMethod("inbox.listener_loading", null)
                        },
                        onError = { error ->
                            channel.invokeMethod("inbox.listener_error", mapOf(
                                "error" to error.message
                            ))
                        },
                        onMessagesChanged = { messages, unreadMessageCount, totalMessageCount, canPaginate ->
                            channel.invokeMethod("inbox.listener_messages_changed", mapOf(
                                "messages" to messages.map { it.toJson() },
                                "unreadMessageCount" to unreadMessageCount,
                                "totalMessageCount" to totalMessageCount,
                                "canPaginate" to canPaginate,
                            ))
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
                    listener.remove()

                    result.success(null)

                }

                "inbox.remove_all_listeners" -> {

                    for (value in inboxListeners.values) {
                        value.remove()
                    }

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
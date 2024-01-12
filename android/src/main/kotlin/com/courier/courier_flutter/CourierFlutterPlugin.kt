package com.courier.courier_flutter

import com.courier.android.BuildConfig
import com.courier.android.Courier
import com.courier.android.models.*
import com.courier.android.modules.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*
import kotlin.collections.HashMap

/** CourierFlutterPlugin */
internal class CourierFlutterPlugin : FlutterPlugin, MethodCallHandler {

    companion object {
        private const val COURIER_ERROR_TAG = "Courier Android SDK Error"
        internal const val CORE_CHANNEL = "courier_flutter_core"
        internal const val EVENTS_CHANNEL = "courier_flutter_events"
        internal const val INBOX_CHANNEL = "courier_flutter_inbox"
    }

    init {
        Courier.USER_AGENT = CourierAgent.FLUTTER_ANDROID
    }

    private var coreChannel: MethodChannel? = null
    private var inboxChannel: MethodChannel? = null

    private var inboxListeners = mutableMapOf<String, CourierInboxListener>()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

        // Get the core channel
        coreChannel = MethodChannel(flutterPluginBinding.binaryMessenger, CORE_CHANNEL).apply {
            setMethodCallHandler(this@CourierFlutterPlugin)
        }

        // Get the inbox channel
        inboxChannel = MethodChannel(flutterPluginBinding.binaryMessenger, INBOX_CHANNEL)

    }

    override fun onMethodCall(call: MethodCall, result: Result) {

        val params = call.arguments as? HashMap<*, *>

        when (call.method) {

            "isDebugging" -> {

                val isDebugging = params?.get("isDebugging") as? Boolean
                Courier.shared.isDebugging = isDebugging ?: BuildConfig.DEBUG
                result.success(isDebugging)

            }

            "userId" -> {

                val userId = Courier.shared.userId
                result.success(userId)

            }

            "getToken" -> {

                val provider = params?.get("provider") as? String

                provider?.let {
                    val token = Courier.shared.getToken(provider = it)
                    result.success(token)
                }

            }

            "setToken" -> {

                val provider = params?.get("provider") as? String
                val token = params?.get("token") as? String

                if (provider == null || token == null) {
                    return
                }

                Courier.shared.setToken(
                    provider = provider,
                    token = token,
                    onSuccess = {
                        result.success(null)
                    },
                    onFailure = { error ->
                        result.error(COURIER_ERROR_TAG, error.message, error)
                    }
                )

            }

            "addInboxListener" -> {

                val listener = Courier.shared.addInboxListener(
                    onInitialLoad = {

                        inboxChannel?.invokeMethod("onInitialLoad", null)

                    },
                    onError = { error ->

                        inboxChannel?.invokeMethod("onError", error.message)

                    },
                    onMessagesChanged = { messages, unreadMessageCount, totalMessageCount, canPaginate ->

                        val json: Map<String, Any> = mapOf(
                            "messages" to messages.map { it.toMap() },
                            "unreadMessageCount" to unreadMessageCount,
                            "totalMessageCount" to totalMessageCount,
                            "canPaginate" to canPaginate
                        )

                        inboxChannel?.invokeMethod("onMessagesChanged", json)

                    }
                )

                // Create an id for the listener
                val id = UUID.randomUUID().toString()
                inboxListeners[id] = listener

                result.success(id)

            }

            "removeInboxListener" -> {

                val id = params?.get("id") as? String

                id?.let {

                    // Remove the listener
                    val listener = inboxListeners[it]
                    listener?.remove()

                    // Remove from map
                    inboxListeners.remove(it)

                    result.success(it)

                }

            }

            "readMessage" -> {

                val id = params?.get("id") as? String

                id?.let {

                    Courier.shared.readMessage(it)

                    result.success(null)

                }

            }

            "unreadMessage" -> {

                val id = params?.get("id") as? String

                id?.let {

                    Courier.shared.unreadMessage(it)

                    result.success(null)

                }

            }

            "readAllInboxMessages" -> {

                Courier.shared.readAllInboxMessages(
                    onSuccess = {
                        result.success(null)
                    },
                    onFailure = { error ->
                        result.error(COURIER_ERROR_TAG, error.message, error)
                    }
                )

            }

            "setInboxPaginationLimit" -> {

                val limit = params?.get("limit") as? Int

                Courier.shared.inboxPaginationLimit = limit ?: Courier.shared.inboxPaginationLimit
                result.success(Courier.shared.inboxPaginationLimit)

            }

            "refreshInbox" -> {

                Courier.shared.refreshInbox {
                    result.success(null)
                }


            }

            "fetchNextPageOfMessages" -> {

                Courier.shared.fetchNextPageOfMessages(
                    onSuccess = { messages ->
                        result.success(messages.map { it.toMap() })
                    },
                    onFailure = { error ->
                        result.error(COURIER_ERROR_TAG, error.message, error)
                    }
                )


            }

            "setBrandId" -> {

                val id = params?.get("id") as? String
                Courier.shared.inboxBrandId = id
                result.success(null)

            }

            "getBrand" -> {

                val brand = Courier.shared.inboxBrand
                result.success(brand?.toMap())

            }

            "getUserPreferences" -> {

                val paginationCursor = params?.get("paginationCursor") as? String

                Courier.shared.getUserPreferences(
                    paginationCursor = paginationCursor,
                    onSuccess = { preferences ->
                        result.success(preferences.toMap())
                    },
                    onFailure = { error ->
                        result.error(COURIER_ERROR_TAG, error.message, error)
                    }
                )

            }

            "getUserPreferencesTopic" -> {

                val topicId = params?.get("topicId") as? String

                topicId?.let {

                    Courier.shared.getUserPreferenceTopic(
                        topicId = it,
                        onSuccess = { topic ->
                            result.success(topic.toMap())
                        },
                        onFailure = { error ->
                            result.error(COURIER_ERROR_TAG, error.message, error)
                        }
                    )

                }

            }

            "putUserPreferencesTopic" -> {

                val topicId = params?.get("topicId") as? String
                val status = params?.get("status") as? String
                val hasCustomRouting = params?.get("hasCustomRouting") as? Boolean
                val customRouting = params?.get("customRouting") as? List<*>

                if (topicId == null || status == null || hasCustomRouting == null || customRouting == null) {
                    return
                }

                Courier.shared.putUserPreferenceTopic(
                    topicId = topicId,
                    status = CourierPreferenceStatus.fromString(status),
                    hasCustomRouting = hasCustomRouting,
                    customRouting = customRouting.map { CourierPreferenceChannel.fromString(it as String) },
                    onSuccess = {
                        result.success(null)
                    },
                    onFailure = { error ->
                        result.error(COURIER_ERROR_TAG, error.message, error)
                    }
                )

            }

            "signIn" -> {

                val accessToken = params?.get("accessToken") as? String
                val clientKey = params?.get("clientKey") as? String
                val userId = params?.get("userId") as? String

                Courier.shared.signIn(
                    accessToken = accessToken ?: "",
                    clientKey = clientKey,
                    userId = userId ?: "",
                    onSuccess = {
                        result.success(null)
                    },
                    onFailure = { error ->
                        result.error(COURIER_ERROR_TAG, error.message, error)
                    }
                )

            }

            "signOut" -> {

                Courier.shared.signOut(
                    onSuccess = {
                        result.success(null)
                    },
                    onFailure = { error ->
                        result.error(COURIER_ERROR_TAG, error.message, error)
                    }
                )

            }

            else -> {
                result.notImplemented()
            }

        }

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        coreChannel?.setMethodCallHandler(null)
    }

}

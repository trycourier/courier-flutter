//
//  CourierSharedMethodHandler.swift
//  courier_flutter
//
//  Created by Michael Miller on 8/7/24.
//

@preconcurrency import Courier_iOS
import Foundation

internal class CourierSharedMethodHandler: CourierFlutterMethodHandler, FlutterPlugin {
    
    static func getChannel(with registrar: FlutterPluginRegistrar) -> FlutterMethodChannel {
        return FlutterMethodChannel(
            name: CourierFlutterChannel.shared.rawValue,
            binaryMessenger: registrar.messenger()
        )
    }
    
    static func register(with registrar: any FlutterPluginRegistrar) {
        registrar.addMethodCallDelegate(
            CourierSharedMethodHandler(),
            channel: CourierSharedMethodHandler.getChannel(with: registrar)
        )
    }
    
    // MARK: Listeners
    private var authenticationListeners = [String: CourierAuthenticationListener]()
    private var inboxListeners = [String: CourierInboxListener]()
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        Task {
            do {
                switch call.method {
                    
                    // MARK: - Client
                    
                case "client.get_options":
                    guard let options = await Courier.shared.client?.options else {
                        result(nil)
                        return
                    }
                    
                    let dict: [String : Any?] = [
                        "jwt": options.jwt,
                        "clientKey": options.clientKey,
                        "userId": options.userId,
                        "connectionId": options.connectionId,
                        "tenantId": options.tenantId,
                        "showLogs": options.showLogs
                    ]
                    
                    result(dict.compactMapValues { $0 })
                    
                    // MARK: - Authentication
                    
                case "auth.user_id":
                    result(await Courier.shared.userId)
                    
                case "auth.tenant_id":
                    result(await Courier.shared.tenantId)
                    
                case "auth.is_user_signed_in":
                    // Return bool directly to Dart
                    result(await Courier.shared.isUserSignedIn)
                    
                case "auth.sign_in":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let userId: String = try params.extract("userId")
                    let tenantId = params["tenantId"] as? String
                    let accessToken: String = try params.extract("accessToken")
                    let clientKey = params["clientKey"] as? String
                    let showLogs: Bool = try params.extract("showLogs")
                    
                    await Courier.shared.signIn(
                        userId: userId,
                        tenantId: tenantId,
                        accessToken: accessToken,
                        clientKey: clientKey,
                        showLogs: showLogs
                    )
                    
                    result(nil)
                    
                case "auth.sign_out":
                    await Courier.shared.signOut()
                    result(nil)
                    
                case "auth.add_authentication_listener":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let listenerId: String = try params.extract("listenerId")
                    
                    // Create the listener
                    let listener = await Courier.shared.addAuthenticationListener { userId in
                        DispatchQueue.main.async {
                            // Fire the event
                            CourierFlutterChannel.events.channel?.invokeMethod(
                                "auth.state_changed",
                                arguments: [
                                    "userId": userId,
                                    "id": listenerId
                                ]
                            )
                        }
                    }
                    
                    // Hold reference to the auth listeners
                    authenticationListeners[listenerId] = listener
                    result(listenerId)
                    
                case "auth.remove_authentication_listener":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let listenerId: String = try params.extract("listenerId")
                    guard let listener = authenticationListeners[listenerId] else {
                        throw CourierFlutterError.invalidParameter(value: "listenerId")
                    }
                    
                    listener.remove()
                    authenticationListeners.removeValue(forKey: listenerId)
                    
                    result(nil)
                    
                case "auth.remove_all_authentication_listeners":
                    for value in authenticationListeners.values {
                        await Courier.shared.removeAuthenticationListener(value)
                    }
                    authenticationListeners.removeAll()
                    result(nil)
                    
                    // MARK: - Push (Tokens)
                    
                case "tokens.get_all_tokens":
                    let tokens = await Courier.shared.tokens
                    result(tokens)
                    
                case "tokens.set_token":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let token: String = try params.extract("token")
                    let provider: String = try params.extract("provider")
                    
                    try await Courier.shared.setToken(for: provider, token: token)
                    result(nil)
                    
                case "tokens.get_token":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let provider: String = try params.extract("provider")
                    let token = await Courier.shared.getToken(for: provider)
                    result(token)
                    
                // If you still need to expose get_apns_token, keep it. Otherwise remove it:
                case "tokens.get_apns_token":
                    let token = await Courier.shared.apnsToken
                    result(token?.string)
                    
                    // MARK: - Inbox
                    
                case "inbox.get_pagination_limit":
                    let limit = await Courier.shared.inboxPaginationLimit
                    result(limit)
                    
                case "inbox.set_pagination_limit":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let limit: Int = try params.extract("limit")
                    await Courier.shared.setPaginationLimit(limit)
                    
                    result(nil)
                    
                case "inbox.refresh":
                    await Courier.shared.refreshInbox()
                    result(nil)
                    
                case "inbox.fetch_next_page":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let feedParam: String = try params.extract("feed")  // "archive" or "feed"
                    
                    let inboxFeed: InboxMessageFeed = (feedParam == "archive") ? .archive : .feed
                    
                    let messageSet = try await Courier.shared.fetchNextInboxPage(inboxFeed)
                    
                    let messagesJson = try messageSet?.messages.map { try $0.toJson() ?? "" }
                    
                    result([
                        "messages": messagesJson ?? [],
                        "totalCount": messageSet?.totalCount ?? 0,
                        "canPaginate": messageSet?.canPaginate ?? false,
                        "paginationCursor": messageSet?.paginationCursor ?? ""
                    ])
                    
                case "inbox.add_listener":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let client = await Courier.shared.client
                    let listenerId: String = try params.extract("listenerId")
                    
                    // Create the listener
                    let listener = await Courier.shared.addInboxListener(
                        onLoading: { isRefresh in
                            DispatchQueue.main.async {
                                CourierFlutterChannel.events.channel?.invokeMethod(
                                    "inbox.listener_loading",
                                    arguments: [
                                        "id": listenerId,
                                        "isRefresh": isRefresh
                                    ]
                                )
                            }
                        },
                        onError: { error in
                            DispatchQueue.main.async {
                                let courierError = CourierError(from: error)
                                CourierFlutterChannel.events.channel?.invokeMethod(
                                    "inbox.listener_error",
                                    arguments: [
                                        "id": listenerId,
                                        "error": courierError.message
                                    ]
                                )
                            }
                        },
                        onUnreadCountChanged: { unreadCount in
                            DispatchQueue.main.async {
                                CourierFlutterChannel.events.channel?.invokeMethod(
                                    "inbox.listener_unread_count_changed",
                                    arguments: [
                                        "id": listenerId,
                                        "count": unreadCount
                                    ]
                                )
                            }
                        },
                        onTotalCountChanged: { totalCount, feed in
                            DispatchQueue.main.async {
                                let feedName = (feed == .archive) ? "archive" : "feed"
                                CourierFlutterChannel.events.channel?.invokeMethod(
                                    "inbox.listener_total_count_changed",
                                    arguments: [
                                        "id": listenerId,
                                        "feed": feedName,
                                        "totalCount": totalCount
                                    ]
                                )
                            }
                        },
                        onMessagesChanged: { messages, canPaginate, feed in
                            DispatchQueue.main.async {
                                do {
                                    let feedName = (feed == .archive) ? "archive" : "feed"
                                    let jsonMessages = try messages.map { try $0.toJson() ?? "" }
                                    CourierFlutterChannel.events.channel?.invokeMethod(
                                        "inbox.listener_messages_changed",
                                        arguments: [
                                            "id": listenerId,
                                            "feed": feedName,
                                            "canPaginate": canPaginate,
                                            "messages": jsonMessages
                                        ]
                                    )
                                } catch {
                                    client?.error(error.localizedDescription)
                                }
                            }
                        },
                        onPageAdded: { messages, canPaginate, isFirstPage, feed in
                            DispatchQueue.main.async {
                                do {
                                    let feedName = (feed == .archive) ? "archive" : "feed"
                                    let jsonMessages = try messages.map { try $0.toJson() ?? "" }
                                    CourierFlutterChannel.events.channel?.invokeMethod(
                                        "inbox.listener_page_added",
                                        arguments: [
                                            "id": listenerId,
                                            "feed": feedName,
                                            "canPaginate": canPaginate,
                                            "isFirstPage": isFirstPage,
                                            "messages": jsonMessages
                                        ]
                                    )
                                } catch {
                                    client?.error(error.localizedDescription)
                                }
                            }
                        },
                        onMessageEvent: { message, index, feed, event in
                            DispatchQueue.main.async {
                                do {
                                    let feedName = (feed == .archive) ? "archive" : "feed"
                                    let messageJson = try message.toJson() ?? ""
                                    let eventName = event.rawValue  // e.g. "added", "changed", "removed"
                                    CourierFlutterChannel.events.channel?.invokeMethod(
                                        "inbox.listener_message_event",
                                        arguments: [
                                            "id": listenerId,
                                            "feed": feedName,
                                            "event": eventName,
                                            "index": index,
                                            "message": messageJson
                                        ]
                                    )
                                } catch {
                                    client?.error(error.localizedDescription)
                                }
                            }
                        }
                    )
                    
                    // Hold reference
                    inboxListeners[listenerId] = listener
                    result(listenerId)
                    
                case "inbox.remove_listener":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let listenerId: String = try params.extract("listenerId")
                    guard let listener = inboxListeners[listenerId] else {
                        throw CourierFlutterError.invalidParameter(value: "listenerId")
                    }
                    
                    await Courier.shared.removeInboxListener(listener)
                    inboxListeners.removeValue(forKey: listenerId)
                    
                    result(nil)
                    
                case "inbox.remove_all_listeners":
                    await Courier.shared.removeAllInboxListeners()
                    inboxListeners.removeAll()
                    result(nil)
                    
                case "inbox.open_message":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    let messageId: String = try params.extract("messageId")
                    try await Courier.shared.openMessage(messageId)
                    result(nil)
                    
                case "inbox.read_message":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    let messageId: String = try params.extract("messageId")
                    try await Courier.shared.readMessage(messageId)
                    result(nil)
                    
                case "inbox.unread_message":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    let messageId: String = try params.extract("messageId")
                    try await Courier.shared.unreadMessage(messageId)
                    result(nil)
                    
                case "inbox.click_message":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    let messageId: String = try params.extract("messageId")
                    try await Courier.shared.clickMessage(messageId)
                    result(nil)
                    
                case "inbox.archive_message":
                    guard let params = call.arguments as? [String: Any] else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    let messageId: String = try params.extract("messageId")
                    try await Courier.shared.archiveMessage(messageId)
                    result(nil)
                    
                case "inbox.read_all_messages":
                    try await Courier.shared.readAllInboxMessages()
                    result(nil)
                    
                default:
                    result(FlutterMethodNotImplemented)
                }
                
            } catch {
                result(error.toFlutterError())
            }
        }
    }
}

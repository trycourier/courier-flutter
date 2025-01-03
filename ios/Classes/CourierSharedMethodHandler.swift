//
//  CourierSharedMethodHandler.swift
//  courier_flutter
//
//  Created by Michael Miller on 8/7/24.
//

import Courier_iOS

internal class CourierSharedMethodHandler: CourierFlutterMethodHandler, FlutterPlugin {
    
    static func getChannel(with registrar: FlutterPluginRegistrar) -> FlutterMethodChannel {
        return FlutterMethodChannel(name: CourierFlutterChannel.shared.rawValue, binaryMessenger: registrar.messenger())
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
                    
                    // MARK: Client
                    
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
                        "showLogs": options.showLogs,
                    ]
                    
                    result(dict)
                    
                    // MARK: Authentication
                    
                case "auth.user_id":
                    
                    result(await Courier.shared.userId)
                    
                case "auth.tenant_id":
                    
                    result(await Courier.shared.tenantId)
                    
                case "auth.is_user_signed_in":
                    
                    result(await Courier.shared.isUserSignedIn)
                    
                case "auth.sign_in":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
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
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let listenerId: String = try params.extract("listenerId")
                    
                    // Create the listener
                    let listener = await Courier.shared.addAuthenticationListener { userId in
                        
                        // Call the event function
                        DispatchQueue.main.async {
                            CourierFlutterChannel.events.channel?.invokeMethod("auth.state_changed", arguments: [
                                "userId": userId,
                                "id": listenerId
                            ])
                        }
                        
                    }
                    
                    // Hold reference to the auth listeners
                    authenticationListeners[listenerId] = listener
                    
                    // Return the id of the listener
                    result(listenerId)
                    
                case "auth.remove_authentication_listener":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let listenerId: String = try params.extract("listenerId")
                    
                    // Get and remove the listener
                    guard let listener = authenticationListeners[listenerId] else {
                        throw CourierFlutterError.invalidParameter(value: "listenerId")
                    }
                    
                    listener.remove()
                    
                    result(nil)
                    
                case "auth.remove_all_authentication_listeners":
                    
                    for value in authenticationListeners.values {
                        value.remove()
                    }
                    
                    authenticationListeners.removeAll()
                    
                    result(nil)
                    
                    // MARK: Push
                    
                case "tokens.get_apns_token":
                    
                    let token = await Courier.shared.apnsToken
                    
                    result(token?.string)
                    
                case "tokens.get_all_tokens":
                    
                    let tokens = await Courier.shared.tokens
                    
                    result(tokens)
                    
                case "tokens.set_token":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let token: String = try params.extract("token")
                    let provider: String = try params.extract("provider")
                    
                    try await Courier.shared.setToken(
                        for: provider,
                        token: token
                    )
                    
                    result(nil)
                    
                case "tokens.get_token":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let provider: String = try params.extract("provider")
                    
                    let token = await Courier.shared.getToken(
                        for: provider
                    )
                    
                    result(token)
                    
                    // MARK: Inbox
                    
                case "inbox.get_pagination_limit":
                    
                    let limit = await Courier.shared.inboxPaginationLimit
                    
                    result(limit)
                    
                case "inbox.set_pagination_limit":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let limit: Int = try params.extract("limit")
                    
                    await Courier.shared.setPaginationLimit(limit)
                    
                    result(nil)
                    
                case "inbox.get_feed_messages":
                    
                    let messages = await Courier.shared.feedMessages
                    
                    let json = try messages.map { try $0.toJson() ?? "" }
                    
                    result(json)
                    
                case "inbox.get_archived_messages":
                    
                    let messages = await Courier.shared.archivedMessages
                    
                    let json = try messages.map { try $0.toJson() ?? "" }
                    
                    result(json)
                    
                case "inbox.refresh":
                    
                    await Courier.shared.refreshInbox()
                    
                    result(nil)
                    
                case "inbox.fetch_next_page":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let feed: String = try params.extract("feed")
                    
                    let inboxFeed: InboxMessageFeed = feed == "archived" ? .archived : .feed
                    
                    let messages = try await Courier.shared.fetchNextInboxPage(inboxFeed)
                    
                    let json = try messages.map { try $0.toJson() ?? "" }
                    
                    result(json)
                    
                case "inbox.add_listener":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let client = await Courier.shared.client
                    
                    let listenerId: String = try params.extract("listenerId")
                    
                    // Create the listener
                    let listener = await Courier.shared.addInboxListener(
                        onLoading: {
                            DispatchQueue.main.async {
                                CourierFlutterChannel.events.channel?.invokeMethod("inbox.listener_loading", arguments: [
                                    "id": listenerId
                                ])
                            }
                        },
                        onError: { error in
                            DispatchQueue.main.async {
                                let courierError = CourierError(from: error)
                                CourierFlutterChannel.events.channel?.invokeMethod("inbox.listener_error", arguments: [
                                    "error": courierError.message,
                                    "id": listenerId
                                ])
                            }
                        },
                        onUnreadCountChanged: { count in
                            DispatchQueue.main.async {
                                CourierFlutterChannel.events.channel?.invokeMethod("inbox.listener_unread_count_changed", arguments: [
                                    "count": count,
                                    "id": listenerId
                                ])
                            }
                        },
                        onFeedChanged: { messageSet in
                            DispatchQueue.main.async {
                                do {
                                    CourierFlutterChannel.events.channel?.invokeMethod("inbox.listener_feed_changed", arguments: [
                                        "messageSet": try messageSet.toJson(),
                                        "id": listenerId
                                    ])
                                } catch {
                                    client?.log(error.localizedDescription)
                                }
                            }
                        },
                        onArchiveChanged: { messageSet in
                            DispatchQueue.main.async {
                                do {
                                    CourierFlutterChannel.events.channel?.invokeMethod("inbox.listener_archive_changed", arguments: [
                                        "messageSet": try messageSet.toJson(),
                                        "id": listenerId
                                    ])
                                } catch {
                                    client?.log(error.localizedDescription)
                                }
                            }
                        },
                        onPageAdded: { feed, page in
                            DispatchQueue.main.async {
                                do {
                                    CourierFlutterChannel.events.channel?.invokeMethod("inbox.listener_page_added", arguments: [
                                        "feed": feed == .archived ? "archived" : "feed",
                                        "page": try page.toJson(),
                                        "id": listenerId
                                    ])
                                } catch {
                                    client?.log(error.localizedDescription)
                                }
                            }
                        },
                        onMessageChanged: { feed, index, message in
                            DispatchQueue.main.async {
                                do {
                                    CourierFlutterChannel.events.channel?.invokeMethod("inbox.listener_message_changed", arguments: [
                                        "feed": feed == .archived ? "archived" : "feed",
                                        "index": index,
                                        "message": try message.toJson() ?? "",
                                        "id": listenerId
                                    ])
                                } catch {
                                    client?.log(error.localizedDescription)
                                }
                            }
                        },
                        onMessageAdded: { feed, index, message in
                            DispatchQueue.main.async {
                                do {
                                    CourierFlutterChannel.events.channel?.invokeMethod("inbox.listener_message_added", arguments: [
                                        "feed": feed == .archived ? "archived" : "feed",
                                        "index": index,
                                        "message": try message.toJson() ?? "",
                                        "id": listenerId
                                    ])
                                } catch {
                                    client?.log(error.localizedDescription)
                                }
                            }
                        },
                        onMessageRemoved: { feed, index, message in
                            DispatchQueue.main.async {
                                do {
                                    CourierFlutterChannel.events.channel?.invokeMethod("inbox.listener_message_removed", arguments: [
                                        "feed": feed == .archived ? "archived" : "feed",
                                        "index": index,
                                        "message": try message.toJson() ?? "",
                                        "id": listenerId
                                    ])
                                } catch {
                                    client?.log(error.localizedDescription)
                                }
                            }
                        }
                    )
                    
                    // Hold reference to the auth listeners
                    inboxListeners[listenerId] = listener
                    
                    // Return the id of the listener
                    result(listenerId)
                    
                case "inbox.remove_listener":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let listenerId: String = try params.extract("listenerId")
                    
                    // Get and remove the listener
                    guard let listener = inboxListeners[listenerId] else {
                        throw CourierFlutterError.invalidParameter(value: "listenerId")
                    }
                    
                    listener.remove()
                    
                    result(nil)
                    
                case "inbox.remove_all_listeners":
                    
                    for value in inboxListeners.values {
                        value.remove()
                    }
                    
                    authenticationListeners.removeAll()
                    
                    result(nil)
                    
                case "inbox.open_message":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let messageId: String = try params.extract("messageId")
                    
                    try await Courier.shared.openMessage(messageId)
                    
                    result(nil)
                    
                case "inbox.read_message":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let messageId: String = try params.extract("messageId")
                    
                    try await Courier.shared.readMessage(messageId)
                    
                    result(nil)
                    
                case "inbox.unread_message":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let messageId: String = try params.extract("messageId")
                    
                    try await Courier.shared.unreadMessage(messageId)
                    
                    result(nil)
                    
                case "inbox.click_message":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierFlutterError.missingParameter(value: "params")
                    }
                    
                    let messageId: String = try params.extract("messageId")
                    
                    try await Courier.shared.clickMessage(messageId)
                    
                    result(nil)
                    
                case "inbox.archive_message":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
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

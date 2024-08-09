//
//  CourierSharedMethodHandler.swift
//  courier_flutter
//
//  Created by Michael Miller on 8/7/24.
//

import Courier_iOS

internal class CourierSharedMethodHandler: NSObject, FlutterPlugin {
    
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
                    
                case "shared.client.get_options":
                    
                    guard let options = Courier.shared.client?.options else {
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
                    
                case "shared.auth.user_id":
                    
                    result(Courier.shared.userId)
                    
                case "shared.auth.tenant_id":
                    
                    result(Courier.shared.tenantId)
                    
                case "shared.auth.is_user_signed_in":
                    
                    result(Courier.shared.isUserSignedIn)
                    
                case "shared.auth.sign_in":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierError.missingParameter(value: "params")
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
                    
                case "shared.auth.sign_out":
                    
                    await Courier.shared.signOut()
                    
                    result(nil)
                    
                case "shared.auth.add_authentication_listener":
                    
                    // Create the listener
                    let listener = Courier.shared.addAuthenticationListener { userId in
                        
                        // Call the event function
                        CourierFlutterChannel.events.channel?.invokeMethod("events.shared.auth.state_changed", arguments: [
                            "userId": userId
                        ])
                        
                    }
                    
                    // Hold reference to the auth listeners
                    let id = UUID().uuidString
                    authenticationListeners[id] = listener
                    
                    // Return the id of the listener
                    result(id)
                    
                case "shared.auth.remove_authentication_listener":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierError.missingParameter(value: "params")
                    }
                    
                    let listenerId: String = try params.extract("listenerId")
                    
                    // Get and remove the listener
                    guard let listener = authenticationListeners[listenerId] else {
                        throw CourierError.invalidParameter(value: "listenerId")
                    }
                    
                    listener.remove()
                    
                    result(nil)
                    
                case "shared.auth.remove_all_authentication_listeners":
                    
                    for value in authenticationListeners.values {
                        value.remove()
                    }
                    
                    authenticationListeners.removeAll()
                    
                    result(nil)
                    
                    // MARK: Push
                    
                case "shared.tokens.get_apns_token":
                    
                    let token = await Courier.shared.apnsToken
                    
                    result(token?.string)
                    
                case "shared.tokens.get_all_tokens":
                    
                    let tokens = await Courier.shared.tokens
                    
                    result(tokens)
                    
                case "shared.tokens.set_token":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierError.missingParameter(value: "params")
                    }
                    
                    let token: String = try params.extract("token")
                    let provider: String = try params.extract("provider")
                    
                    try await Courier.shared.setToken(
                        for: provider,
                        token: token
                    )
                    
                    result(nil)
                    
                case "shared.tokens.get_token":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierError.missingParameter(value: "params")
                    }
                    
                    let provider: String = try params.extract("provider")
                    
                    let token = await Courier.shared.getToken(
                        for: provider
                    )
                    
                    result(token)
                    
                    // MARK: Inbox
                    
                case "shared.inbox.get_pagination_limit":
                    
                    let limit = Courier.shared.inboxPaginationLimit
                    
                    result(limit)
                    
                case "shared.inbox.set_pagination_limit":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierError.missingParameter(value: "params")
                    }
                    
                    let limit: Int = try params.extract("limit")
                    
                    Courier.shared.inboxPaginationLimit = limit
                    
                    result(nil)
                    
                case "shared.inbox.get_messages":
                    
                    let messages = await Courier.shared.inboxMessages
                    
                    let json = messages.map { $0.toDictionary() }
                    
                    result(json)
                    
                case "shared.inbox.refresh":
                    
                    await Courier.shared.refreshInbox()
                    
                    result(nil)
                    
                case "shared.inbox.fetch_next_page":
                    
                    let messages = try await Courier.shared.fetchNextInboxPage()
                    
                    let json = messages.map { $0.toDictionary() }
                    
                    result(json)
                    
                case "shared.inbox.add_listener":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierError.missingParameter(value: "params")
                    }
                    
                    let listenerId: String = try params.extract("listenerId")
                    
                    let channel = CourierFlutterChannel.events.channel
                    
                    // Create the listener
                    let listener = Courier.shared.addInboxListener(
                        onInitialLoad: {
                            channel?.invokeMethod("events.shared.inbox.listener_loading", arguments: nil)
                        },
                        onError: { error in
                            channel?.invokeMethod("events.shared.inbox.listener_error", arguments: [
                                "error": error.localizedDescription
                            ])
                        },
                        onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
                            let json: [String: Any] = [
                                "messages": messages.map { $0.toDictionary().toJson() },
                                "unreadMessageCount": unreadMessageCount,
                                "totalMessageCount": totalMessageCount,
                                "canPaginate": canPaginate
                            ]
                            channel?.invokeMethod("events.shared.inbox.listener_messages_changed", arguments: json)
                        }
                    )
                    
                    // Hold reference to the auth listeners
                    inboxListeners[listenerId] = listener
                    
                    // Return the id of the listener
                    result(listenerId)
                    
                case "shared.inbox.remove_listener":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierError.missingParameter(value: "params")
                    }
                    
                    let listenerId: String = try params.extract("listenerId")
                    
                    // Get and remove the listener
                    guard let listener = inboxListeners[listenerId] else {
                        throw CourierError.invalidParameter(value: "listenerId")
                    }
                    
                    listener.remove()
                    
                    result(nil)
                    
                case "shared.inbox.remove_all_listeners":
                    
                    for value in inboxListeners.values {
                        value.remove()
                    }
                    
                    authenticationListeners.removeAll()
                    
                    result(nil)
                    
                case "shared.inbox.open_message":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierError.missingParameter(value: "params")
                    }
                    
                    let messageId: String = try params.extract("messageId")
                    
                    try await Courier.shared.openMessage(messageId)
                    
                    result(nil)
                    
                case "shared.inbox.read_message":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierError.missingParameter(value: "params")
                    }
                    
                    let messageId: String = try params.extract("messageId")
                    
                    try await Courier.shared.readMessage(messageId)
                    
                    result(nil)
                    
                case "shared.inbox.unread_message":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierError.missingParameter(value: "params")
                    }
                    
                    let messageId: String = try params.extract("messageId")
                    
                    try await Courier.shared.unreadMessage(messageId)
                    
                    result(nil)
                    
                case "shared.inbox.click_message":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierError.missingParameter(value: "params")
                    }
                    
                    let messageId: String = try params.extract("messageId")
                    
                    try await Courier.shared.clickMessage(messageId)
                    
                    result(nil)
                    
                case "shared.inbox.archive_message":
                    
                    guard let params = call.arguments as? Dictionary<String, Any> else {
                        throw CourierError.missingParameter(value: "params")
                    }
                    
                    let messageId: String = try params.extract("messageId")
                    
                    try await Courier.shared.archiveMessage(messageId)
                    
                    result(nil)
                    
                case "shared.inbox.read_all_messages":
                    
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

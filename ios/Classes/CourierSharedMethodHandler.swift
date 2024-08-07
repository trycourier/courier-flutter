//
//  CourierSharedMethodHandler.swift
//  courier_flutter
//
//  Created by Michael Miller on 8/7/24.
//

import Courier_iOS

internal class CourierSharedMethodHandler: NSObject, FlutterPlugin {
    
    static let name = "courier_flutter_shared"
    
    static func getChannel(with registrar: FlutterPluginRegistrar) -> FlutterMethodChannel {
        return FlutterMethodChannel(name: CourierSharedMethodHandler.name, binaryMessenger: registrar.messenger())
    }
    
    static func register(with registrar: any FlutterPluginRegistrar) {
        registrar.addMethodCallDelegate(
            CourierSharedMethodHandler(),
            channel: CourierSharedMethodHandler.getChannel(with: registrar)
        )
    }
    
    private var inboxListeners = [String: CourierInboxListener]()
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        Task {
            
            do {
                
                guard let params = call.arguments as? Dictionary<String, Any> else {
                    throw CourierError.missingParameter(value: "params")
                }
                
                switch call.method {
                    
                    // MARK: Authentication
                    
                case "shared.auth.sign_in":
                    
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
                    
                    // MARK: Inbox
                    
//                case "shared.inbox.add_inbox_listener":
//                    
//                    let channel = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.messanger?.channel(id: CourierFlutterPlugin.INBOX_CHANNEL)
//
//                    // Register the listener
//                    let listener = Courier.shared.addInboxListener(
//                        onInitialLoad: {
//                            
//                            channel?.invokeMethod("onInitialLoad", arguments: nil)
//                            
//                        },
//                        onError: { error in
//                            
//                            channel?.invokeMethod("onError", arguments: String(describing: error))
//                            
//                        },
//                        onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
//                            
//                            let json: [String: Any] = [
//                                "messages": messages.map { $0.toDictionary() },
//                                "unreadMessageCount": unreadMessageCount,
//                                "totalMessageCount": totalMessageCount,
//                                "canPaginate": canPaginate
//                            ]
//                            
//                            channel?.invokeMethod("onMessagesChanged", arguments: json)
//                            
//                        }
//                    )
//                    
//                    // Create an id and add the listener to the dictionary
//                    let id = UUID().uuidString
//                    inboxListeners[id] = listener
//                    
//                    result(id)
                
                    
                default:
                    
                    result(FlutterMethodNotImplemented)
                    
                }
                
            } catch {
                
                result(error.toFlutterError())
                
            }
            
        }
          
    }
    
}

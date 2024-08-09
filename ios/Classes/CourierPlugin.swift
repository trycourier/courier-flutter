import Flutter
import UIKit
import Courier_iOS

public class CourierPlugin: NSObject, FlutterPlugin {
    
    public override init() {
        super.init()
        Courier.agent = CourierAgent.flutter_ios
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        CourierSharedMethodHandler.register(with: registrar)
        CourierClientMethodHandler.register(with: registrar)
    }

//    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        
//        let params = call.arguments as? Dictionary<String, Any>
          
//        switch call.method {
//            
//        case "addInboxListener":
//            
//            let channel = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.messanger?.channel(id: CourierFlutterPlugin.INBOX_CHANNEL)
//
//            // Register the listener
//            let listener = Courier.shared.addInboxListener(
//                onInitialLoad: {
//                    
//                    channel?.invokeMethod("onInitialLoad", arguments: nil)
//                    
//                },
//                onError: { error in
//                    
//                    channel?.invokeMethod("onError", arguments: String(describing: error))
//                    
//                },
//                onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
//                    
//                    let json: [String: Any] = [
//                        "messages": messages.map { $0.toDictionary() },
//                        "unreadMessageCount": unreadMessageCount,
//                        "totalMessageCount": totalMessageCount,
//                        "canPaginate": canPaginate
//                    ]
//                    
//                    channel?.invokeMethod("onMessagesChanged", arguments: json)
//                    
//                }
//            )
//            
//            // Create an id and add the listener to the dictionary
//            let id = UUID().uuidString
//            inboxListeners[id] = listener
//            
//            result(id)
//            
//        case "removeInboxListener":
//            
//            if let id = params?["id"] as? String {
//                        
//                // Remove the listener
//                let listener = inboxListeners[id]
//                listener?.remove()
//                
//                // Remove from dictionary
//                inboxListeners.removeValue(forKey: id)
//                
//                result(id)
//                
//            }
//            
//        case "setInboxPaginationLimit":
//            
//            if let limit = params?["limit"] as? Int {
//                
//                Courier.shared.inboxPaginationLimit = limit
//                result(Courier.shared.inboxPaginationLimit)
//                
//            }
//            
//        case "refreshInbox":
//            
//            Courier.shared.refreshInbox {
//                result(nil)
//            }
//            
//        case "fetchNextPageOfMessages":
//            
//            Courier.shared.fetchNextPageOfMessages(
//                onSuccess: { messages in
//                    
//                    let msgs = messages.map { $0.toDictionary() }
//                    result(msgs)
//                    
//                },
//                onFailure: { error in
//                    
//                    result(FlutterError.init(code: CourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
//                    
//                }
//            )
//            
//        case "clickMessage":
//            
//            if let id = params?["id"] as? String {
//                
//                Courier.shared.clickMessage(
//                    messageId: id,
//                    onSuccess: {
//                        result(nil)
//                    },
//                    onFailure: { error in
//                        result(FlutterError.init(code: CourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
//                    }
//                )
//                
//            }
//            
//        case "readMessage":
//            
//            if let id = params?["id"] as? String {
//                
//                Courier.shared.readMessage(
//                    messageId: id,
//                    onSuccess: {
//                        result(nil)
//                    },
//                    onFailure: { error in
//                        result(FlutterError.init(code: CourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
//                    }
//                )
//                
//            }
//            
//        case "unreadMessage":
//            
//            if let id = params?["id"] as? String {
//                
//                Courier.shared.unreadMessage(
//                    messageId: id,
//                    onSuccess: {
//                        result(nil)
//                    },
//                    onFailure: { error in
//                        result(FlutterError.init(code: CourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
//                    }
//                )
//                
//            }
//            
//        case "readAllInboxMessages":
//            
//            Courier.shared.readAllInboxMessages(
//                onSuccess: {
//                    result(nil)
//                },
//                onFailure: { error in
//                    result(FlutterError.init(code: CourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
//                }
//            )
//            
//        case "getBrand":
//            
//            if let id = params?["id"] as? String {
//                
//                Courier.shared.getBrand(
//                    brandId: id,
//                    onSuccess: { brand in
//                        result(brand.toDictionary())
//                    }, onFailure: { error in
//                        result(FlutterError.init(code: CourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
//                    }
//                )
//                
//            }
//            
//        case "getUserPreferences":
//            
//            let paginationCursor = params?["paginationCursor"] as? String
//            
//            Courier.shared.getUserPreferences(
//                paginationCursor: paginationCursor,
//                onSuccess: { preferences in
//                    result(preferences.toDictionary())
//                },
//                onFailure: { error in
//                    result(FlutterError.init(code: CourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
//                }
//            )
//            
//        case "getUserPreferencesTopic":
//            
//            if let topicId = params?["topicId"] as? String {
//                
//                Courier.shared.getUserPreferencesTopic(
//                    topicId: topicId,
//                    onSuccess: { topic in
//                        result(topic.toDictionary())
//                    },
//                    onFailure: { error in
//                        result(FlutterError.init(code: CourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
//                    }
//                )
//                
//            }
//            
//        case "putUserPreferencesTopic":
//            
//            if let topicId = params?["topicId"] as? String, let status = params?["status"] as? String, let hasCustomRouting = params?["hasCustomRouting"] as? Bool, let customRouting = params?["customRouting"] as? [String] {
//                
//                Courier.shared.putUserPreferencesTopic(
//                    topicId: topicId,
//                    status: CourierUserPreferencesStatus(rawValue: status) ?? .unknown,
//                    hasCustomRouting: hasCustomRouting,
//                    customRouting: customRouting.map { CourierUserPreferencesChannel(rawValue: $0) ?? .unknown },
//                    onSuccess: {
//                        result(nil)
//                    },
//                    onFailure: { error in
//                        result(FlutterError.init(code: CourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
//                    }
//                )
//                
//            }
//            
//        case "isDebugging":
//            
//            if let isDebugging = params?["isDebugging"] as? Bool {
//                
//                Courier.shared.isDebugging = isDebugging
//                result(isDebugging)
//                
//            }
//            
//        case "userId":
//
//            let userId = Courier.shared.userId
//            result(userId)
//            
//        case "tenantId":
//
//            let tenantId = Courier.shared.tenantId
//            result(tenantId)
//            
//        case "getToken":
//
//            if let provider = params?["provider"] as? String {
//                
//                Task {
//                    let token = await Courier.shared.getToken(providerKey: provider)
//                    result(token)
//                }
//                
//            }
//            
//        case "setToken":
//
//            if let provider = params?["provider"] as? String, let token = params?["token"] as? String {
//                
//                Courier.shared.setToken(
//                    providerKey: provider,
//                    token: token,
//                    onSuccess: {
//                        result(nil)
//                    },
//                    onFailure: { error in
//                        result(FlutterError.init(code: CourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
//                    }
//                )
//                
//            }
//            
//        case "signIn":
//
//            if let accessToken = params?["accessToken"] as? String, let userId = params?["userId"] as? String {
//                
//                let clientKey = params?["clientKey"] as? String
//                let tenantId = params?["tenantId"] as? String
//
//                Courier.shared.signIn(accessToken: accessToken, clientKey: clientKey, userId: userId, tenantId: tenantId) {
//                    result(nil)
//                }
//            
//            }
//            
//        case "signOut":
//            
//            Courier.shared.signOut {
//                result(nil)
//            }
//            
//        default:
//            
//            result(FlutterMethodNotImplemented)
//            
//        }
          
//    }
    
}

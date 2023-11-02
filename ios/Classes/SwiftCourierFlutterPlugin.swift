import Flutter
import UIKit
import Courier_iOS

public class SwiftCourierFlutterPlugin: NSObject, FlutterPlugin {
    
    private static let COURIER_ERROR_TAG = "Courier iOS SDK Error"
    internal static let CORE_CHANNEL = "courier_flutter_core"
    internal static let EVENTS_CHANNEL = "courier_flutter_events"
    internal static let INBOX_CHANNEL = "courier_flutter_inbox"
    
    private var inboxListeners = [String: CourierInboxListener]()
    
    public override init() {
        super.init()
        
        Courier.agent = CourierAgent.flutter_ios
        
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CORE_CHANNEL, binaryMessenger: registrar.messenger())
        let instance = SwiftCourierFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          
        switch call.method {
            
        case "addInboxListener":
            
            let channel = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.messanger?.channel(id: SwiftCourierFlutterPlugin.INBOX_CHANNEL)

            // Register the listener
            let listener = Courier.shared.addInboxListener(
                onInitialLoad: {
                    
                    channel?.invokeMethod("onInitialLoad", arguments: nil)
                    
                },
                onError: { error in
                    
                    channel?.invokeMethod("onError", arguments: String(describing: error))
                    
                },
                onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
                    
                    let json: [String: Any] = [
                        "messages": messages.map { $0.toDictionary() },
                        "unreadMessageCount": unreadMessageCount,
                        "totalMessageCount": totalMessageCount,
                        "canPaginate": canPaginate
                    ]
                    
                    channel?.invokeMethod("onMessagesChanged", arguments: json)
                    
                }
            )
            
            // Create an id and add the listener to the dictionary
            let id = UUID().uuidString
            inboxListeners[id] = listener
            
            result(id)
            
        case "removeInboxListener":
            
            if let params = call.arguments as? Dictionary<String, Any>,
                let id = params["id"] as? String {
                        
                // Remove the listener
                let listener = inboxListeners[id]
                listener?.remove()
                
                // Remove from dictionary
                inboxListeners.removeValue(forKey: id)
                
                result(id)
                
            }
            
        case "setInboxPaginationLimit":
            
            if let params = call.arguments as? Dictionary<String, Any>,
                let limit = params["limit"] as? Int {
                
                Courier.shared.inboxPaginationLimit = limit
                result(Courier.shared.inboxPaginationLimit)
                
            }
            
        case "fetchNextPageOfMessages":
            
            Courier.shared.fetchNextPageOfMessages(
                onSuccess: { messages in
                    
                    let msgs = messages.map { $0.toDictionary() }
                    result(msgs)
                    
                },
                onFailure: { error in
                    
                    result(FlutterError.init(code: SwiftCourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
                    
                }
            )
            
        case "isDebugging":
            
            if let params = call.arguments as? Dictionary<String, Any>,
                let isDebugging = params["isDebugging"] as? Bool {
                
                Courier.shared.isDebugging = isDebugging
                result(isDebugging)
                
            }
            
        case "userId":

            let userId = Courier.shared.userId
            result(userId)
            
        case "apnsToken":

            let token = Courier.shared.apnsToken
            result(token)
            
        case "fcmToken":

            let token = Courier.shared.fcmToken
            result(token)
            
        case "setFcmToken":

            if let params = call.arguments as? Dictionary<String, Any>,
                let token = params["token"] as? String {
                
                Courier.shared.setFCMToken(
                    token,
                    onSuccess: {
                        result(nil)
                    },
                    onFailure: { error in
                        result(FlutterError.init(code: SwiftCourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
                    })
                
            }
            
        case "signIn":

            if let params = call.arguments as? Dictionary<String, Any>,
                let accessToken = params["accessToken"] as? String,
                let userId = params["userId"] as? String {
                
                let clientKey = params["clientKey"] as? String

                Courier.shared.signIn(
                    accessToken: accessToken,
                    clientKey: clientKey,
                    userId: userId,
                    onSuccess: {
                        result(nil)
                    },
                    onFailure: { error in
                        result(FlutterError.init(code: SwiftCourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
                    })
            
            }
            
        case "signOut":
            
            Courier.shared.signOut(
                onSuccess: {
                    result(nil)
                },
                onFailure: { error in
                    result(FlutterError.init(code: SwiftCourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
                })
            
        default:
            
            result(FlutterMethodNotImplemented)
            
        }
          
    }
    
}

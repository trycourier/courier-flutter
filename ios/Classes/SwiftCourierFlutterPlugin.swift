import Flutter
import UIKit
import Courier_iOS

public class SwiftCourierFlutterPlugin: NSObject, FlutterPlugin {
    
    private static let COURIER_ERROR_TAG = "Courier iOS SDK Error"
    internal static let CORE_CHANNEL = "courier_flutter_core"
    internal static let EVENTS_CHANNEL = "courier_flutter_events"
    
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

                Courier.shared.signIn(
                    accessToken: accessToken,
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
            
        case "sendPush":
            
            if let params = call.arguments as? Dictionary<String, Any>,
                let authKey = params["authKey"] as? String,
                let userId = params["userId"] as? String,
                let title = params["title"] as? String,
                let body = params["body"] as? String,
                let providers = params["providers"] as? [String] {
                
                let courierProviders = providers.map { provider in
                    return CourierProvider(rawValue: provider) ?? .unknown
                }
                
                Courier.shared.sendPush(
                    authKey: authKey,
                    userId: userId,
                    title: title,
                    message: body,
                    providers: courierProviders,
                    onSuccess: { requestId in
                        result(requestId)
                    },
                    onFailure: { error in
                        result(FlutterError.init(code: SwiftCourierFlutterPlugin.COURIER_ERROR_TAG, message: String(describing: error), details: nil))
                    })
  
            }
            
        default:
            
            result(FlutterMethodNotImplemented)
            
        }
          
    }
    
}

extension UNAuthorizationStatus {
    
    var name: String {
        switch (self) {
        case .notDetermined: return "notDetermined"
        case .denied:        return "denied"
        case .authorized:    return "authorized"
        case .provisional:   return "provisional"
        case .ephemeral:     return "ephemeral"
        @unknown default:    return "unknown"
        }
    }
    
}

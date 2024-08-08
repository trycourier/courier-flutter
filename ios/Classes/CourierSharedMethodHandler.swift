//
//  CourierSharedMethodHandler.swift
//  courier_flutter
//
//  Created by Michael Miller on 8/7/24.
//

import Courier_iOS

internal class CourierSharedMethodHandler: NSObject, FlutterPlugin {
    
    static func getChannel(with registrar: FlutterPluginRegistrar) -> FlutterMethodChannel {
        return FlutterMethodChannel(name: CourierChannel.shared.rawValue, binaryMessenger: registrar.messenger())
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
                        CourierChannel.events.channel?.invokeMethod("events.shared.auth.state_changed", arguments: [
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
                
                    
                default:
                    
                    result(FlutterMethodNotImplemented)
                    
                }
                
            } catch {
                
                result(error.toFlutterError())
                
            }
            
        }
          
    }
    
}

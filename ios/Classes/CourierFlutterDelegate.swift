//
//  CourierFlutterAppDelegate.swift
//  courier_flutter
//
//  Created by Michael Miller on 10/3/22.
//

import UIKit
import Flutter
import Courier_iOS

@available(iOSApplicationExtension, unavailable)
open class CourierFlutterDelegate: FlutterAppDelegate {
    
    // MARK: Getters
    
    private var app: UIApplication {
        get {
            return UIApplication.shared
        }
    }
    
    private var notificationCenter: UNUserNotificationCenter {
        get {
            return UNUserNotificationCenter.current()
        }
    }
    
    // MARK: Props
    
    private var methodChannel: FlutterMethodChannel? = nil
    private var lastClickedPushNotification: [AnyHashable : Any?]? = nil
    private var foregroundPresentationOptions: UNNotificationPresentationOptions = []
    
    // MARK: Init
    
    override init() {
        super.init()
        
        app.registerForRemoteNotifications()
        notificationCenter.delegate = self
        
    }
    
    // MARK: Events
    
    open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Register and instance of a flutter engine
        if let flutterViewController = window?.rootViewController as? FlutterViewController, let binaryMessenger = flutterViewController as? FlutterBinaryMessenger {

            // Create a method channel to listen to platform events
            methodChannel = FlutterMethodChannel(name: SwiftCourierFlutterPlugin.EVENTS_CHANNEL, binaryMessenger: binaryMessenger)
            methodChannel?.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

                switch call.method {

                    case "requestNotificationPermission":

                        Courier.requestNotificationPermission { status in
                            result(status.name)
                        }

                    case "getNotificationPermissionStatus":

                        Courier.getNotificationPermissionStatus { status in
                            result(status.name)
                        }

                    case "openSettingsForApp":

                        Courier.openSettingsForApp()
                        result(nil)
                    
                    case "getClickedNotification":

                    
                        // Fetch the last push notification that was clicked
                        if let self = self, let _ = self.lastClickedPushNotification {
                            
                            // Seems to be working well on iOS
                            // Commented out for now
                            // self.methodChannel?.invokeMethod("pushNotificationClicked", arguments: lastPush)
                            self.lastClickedPushNotification = nil
                            
                        }
                    
                        result(nil)
                    
                    case "iOSForegroundPresentationOptions":
                        
                        if let params = call.arguments as? Dictionary<String, Any>,
                            let options = params["options"] as? [String] {
                            
                            // Clear out and add presentation optionset
                            self?.foregroundPresentationOptions = []
                            options.forEach { option in
                                switch option {
                                case "sound": self?.foregroundPresentationOptions.insert(.sound)
                                case "badge": self?.foregroundPresentationOptions.insert(.badge)
                                case "list": if #available(iOS 14.0, *) { self?.foregroundPresentationOptions.insert(.list) } else { self?.foregroundPresentationOptions.insert(.alert) }
                                case "banner": if #available(iOS 14.0, *) { self?.foregroundPresentationOptions.insert(.banner) } else { self?.foregroundPresentationOptions.insert(.alert) }
                                default: break
                                }
                            }
                            
                        }
                        
                        result(nil)

                    default:

                        result(FlutterMethodNotImplemented)

                }

            })

        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }
    
    // MARK: Messaging
    
    public override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let content = notification.request.content
        let message = content.userInfo
        
        Courier.shared.trackNotification(message: message, event: .delivered)

        let pushNotification = Courier.formatPushNotification(content: content)
        methodChannel?.invokeMethod("pushNotificationDelivered", arguments: pushNotification)
        
        completionHandler(foregroundPresentationOptions)
        
    }
    
    public override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let content = response.notification.request.content
        let message = content.userInfo
        
        Courier.shared.trackNotification(message: message, event: .clicked)
        
        let pushNotification = Courier.formatPushNotification(content: content)
        lastClickedPushNotification = pushNotification
        methodChannel?.invokeMethod("pushNotificationClicked", arguments: pushNotification)
        
        completionHandler()
        
    }
    
    // MARK: Token Management

    public override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Courier.log("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    public override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task {
            do {
                try await Courier.shared.setAPNSToken(deviceToken)
            } catch {
                Courier.log(String(describing: error))
            }
        }
    }
    
}

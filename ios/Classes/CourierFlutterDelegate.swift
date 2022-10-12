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
    private var lastClickedMessage: [AnyHashable : Any]? = nil
    
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
                        if let self = self, let lastMessage = self.lastClickedMessage {
                            self.methodChannel?.invokeMethod("pushNotificationClicked", arguments: lastMessage)
                            self.lastClickedMessage = nil
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
        
        let message = notification.request.content.userInfo
        
        Task {
            
            do {
                try await Courier.shared.trackNotification(message: message, event: .delivered)
            } catch {
                Courier.log(String(describing: error))
            }
            
        }
        
        methodChannel?.invokeMethod("pushNotificationDelivered", arguments: message)
        
        // TODO:
        if #available(iOS 14.0, *) {
            completionHandler([.sound, .list, .banner, .badge])
        } else {
            completionHandler([.sound, .badge])
        }
        
    }
    
    public override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let message = response.notification.request.content.userInfo
        
        Courier.shared.trackNotification(message: message, event: .clicked)
        lastClickedMessage = message
        methodChannel?.invokeMethod("pushNotificationClicked", arguments: message)
        
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
    
    // MARK: Functions
    
//    open func deviceTokenDidChange(rawApnsToken: Data, isDebugging: Bool) {}
    
}

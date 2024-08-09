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
    private var channel: FlutterMethodChannel? {
        get {
            return CourierFlutterChannel.shared.channel
        }
    }
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
        
        if let fvc = window?.rootViewController as? FlutterViewController, let bm = fvc as? FlutterBinaryMessenger {
            
            let methodChannel = FlutterMethodChannel(name: "courier_flutter_system", binaryMessenger: bm)
            
            methodChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                
                switch call.method {
                    
                case "notifications.request_permission":

                    Courier.requestNotificationPermission { status in
                        result(status.name)
                    }

                case "notifications.get_permission_status":

                    Courier.getNotificationPermissionStatus { status in
                        result(status.name)
                    }

                case "app.open_settings":

                    Courier.openSettingsForApp()
                    result(nil)

                case "notifications.get_clicked_notification":

                    // Fetch the last push notification that was clicked
                    if let self = self, let _ = self.lastClickedPushNotification {
                        self.lastClickedPushNotification = nil
                    }

                    result(nil)
                    
                case "ios.set_foreground_presentation_options":
                    
                    if let params = call.arguments as? Dictionary<String, Any>, let options = params["options"] as? [String] {
                        
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
                        
                        result(options)
                        return
                        
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
    
    open override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let content = notification.request.content
        let message = content.userInfo
        
        // Track the message in Courier
        Task {
            do {
                if let trackingUrl = message["trackingUrl"] as? String {
                    try await CourierClient.default.tracking.postTrackingUrl(
                        url: trackingUrl,
                        event: .delivered
                    )
                }
            } catch {
                Courier.shared.client?.options.error(error.localizedDescription)
            }
        }

        let pushNotification = Courier.formatPushNotification(content: content)
        CourierFlutterChannel.events.channel?.invokeMethod("push.delivered", arguments: pushNotification)
        
        completionHandler(foregroundPresentationOptions)
        
    }
    
    open override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let content = response.notification.request.content
        let message = content.userInfo
        
        // Track the message in Courier
        Task {
            do {
                if let trackingUrl = message["trackingUrl"] as? String {
                    try await CourierClient.default.tracking.postTrackingUrl(
                        url: trackingUrl,
                        event: .clicked
                    )
                }
            } catch {
                Courier.shared.client?.options.error(error.localizedDescription)
            }
        }
        
        let pushNotification = Courier.formatPushNotification(content: content)
        lastClickedPushNotification = pushNotification
        CourierFlutterChannel.events.channel?.invokeMethod("push.clicked", arguments: pushNotification)
        
        completionHandler()
        
    }
    
    // MARK: Token Management

    open override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Courier.shared.client?.error("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    open override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task {
            do {
                try await Courier.shared.setAPNSToken(deviceToken)
            } catch {
                Courier.shared.client?.error(String(describing: error))
            }
        }
    }
    
}

//
//  LCMessaging.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 12/07/2024.
//

import Foundation
import UserNotifications
import Firebase

public class LCMessaging: NSObject, MessagingDelegate {
    
    public func configure() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        Messaging.messaging().delegate = self
    }
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
    }
    
    public func application(_ application: UIApplication,
                              didReceiveRemoteNotification data: [AnyHashable: Any],
                              fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        LCLog.logI(message: "Framework received data message: \(data)")
//        var action: String? = data["action"] as! String?
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
//    public func messaging(_ messaging: Messaging, didReceive remoteMessage: [AnyHashable: Any]) {
//        print("Framework received data message: \(remoteMessage)")
//        print("Live Chat SDK da nhan: \(remoteMessage)")
//    }
}

////
////  LCMessaging.swift
////  LiveChatSDK
////
////  Created by Dev App Mitek on 12/07/2024.
////
//
//import Foundation
//import UserNotifications
////import Firebase
//import UIKit
//
//public class LCMessaging : NSObject {
//    
//    public static let shared = LCMessaging()
//    
//    private override init() {
//        super.init()
//        // Thiết lập delegate
//        Messaging.messaging().delegate = self
//    }
//    
//    public func configure() {
////        FirebaseApp.configure()
//    }
//    
//    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("Framework Firebase registration token: \(String(describing: fcmToken))")
//    }
//    
//    public func messaging(_ messaging: Messaging, didReceive remoteMessage: [AnyHashable: Any]) {
//        print("Framework received data message: \(remoteMessage)")
//        print("Live Chat SDK da nhan: \(remoteMessage)")
//    }
//}

//
//  LCMessaging.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 12/07/2024.
//

import Foundation
import UserNotifications
import Firebase
import UIKit

open class LCMessaging: NSObject, UNUserNotificationCenterDelegate {
    
    public func configure(){
        FirebaseApp.configure()
    }
    
    open func application(_ application: UIApplication,
                              didReceiveRemoteNotification data: [AnyHashable: Any],
                              fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        LCLog.logI(message: "Framework received data message: \(data)")
        do {
            let dataDict = Dictionary(uniqueKeysWithValues: data.compactMap { k, v -> (String, Any)? in
                if let ks = k as? String {
                    return (ks, v)
                }
                return nil
            })
            let contentRaw = dataDict["content"] as! [String:Any]
            let fromRaw = dataDict["sender"] as! [String: Any]
            let lcMessage = LCMessage(
                id: dataDict["id"] as! Int,
                content: LCParseUtil.contentFrom(contentRaw: contentRaw),
                from: LCSender(
                    id: fromRaw["id"] as! String,
                    name: fromRaw["name"] as! String
                ),
                timeCreated: fromRaw["created_at"] as! String
            )
            LiveChatSDK.observingMessage(lcMesasge: lcMessage)
        } catch{
            LCLog.logI(message: "Error parse data \(error)")
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

//
//  LCLog.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

public class LCLog {
    private static var TAG = "Live-Chat-SDK-Log"
    
    static func logI(message: String){
        if(LiveChatSDK.isDebuging){
            print(TAG+": \(message)")
        }
    }
}

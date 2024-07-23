//
//  LiveChatFactory.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 05/07/2024.
//

import Foundation

public class LiveChatFactory {
    public static func initializeSDK() {
        LiveChatSDK.initializeSDK()
    }
    
    public static func sendFileMessage(paths: [String], lcUser: LCUser, lcSession: LCSession){
        
    }
    
    public static func initializeSession(user: LCUser, supportType: LCSupportType){
        
    }
    
    public static func authorize(apiKey: String){
        
    }
    
    public static func addEventListener(listener: LCListener){
        LiveChatSDK.addEventListener(listener: listener)
    }
    
    public static func sendMessage(lcUser: LCUser, message: LCMessageSend){
        
    }
    
    public static func getMessages(sessionId: String, offset: Int = 0, limit: Int = 5){
        
    }
}

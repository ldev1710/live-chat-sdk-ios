//
//  LCListener.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

public class LCListener: LCProtocol {
    func onReceiveMessage(lcMessage: LCMessage) {
        
    }
    
    func onGotDetailConversation(messages: [LCMessage]) {
        
    }
    
    func onInitSDKStateChange(state: LCInitialEnum, message: String) {
        
    }
    
    func onAuthstateChanged(success: Bool, message: String, lcAccount: LCAccount?) {
        
    }
    
    func onInitialSessionStateChanged(success: Bool, lcSession: LCSession) {
        
    }
    
    func onSendMessageStateChange(state: LCSendMessageEnum, message: LCMessage?, errorMessage: String?) {
        
    }
}

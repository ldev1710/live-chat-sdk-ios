//
//  LCListener.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

open class LCListener: LCProtocol {
    
    public init() {
        
    }
    
    open func onReceiveMessage(lcMessage: LCMessage) {
        
    }
    
    open func onGotDetailConversation(messages: [LCMessage]) {
        
    }
    
    open func onInitSDKStateChange(state: LCInitialEnum, message: String) {
        
    }
    
    open func onAuthstateChanged(success: Bool, message: String, lcAccount: LCAccount?) {
        
    }
    
    open func onInitialSessionStateChanged(success: Bool, lcSession: LCSession) {
        
    }
    
    open func onSendMessageStateChange(state: LCSendMessageEnum, message: LCMessage?, errorMessage: String?) {
        
    }
}

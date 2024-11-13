//
//  LCListener.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

open class LCListener: LCProtocol {
    public let id = UUID().uuidString
    
    private var onReceiveMessage: (LCMessage)->()
    private var onGotDetailConversation: ([LCMessage]) -> ()
    private var onInitSDKStateChange: (LCInitialEnum,String)->()
    private var onAuthstateChanged: (Bool,String,LCAccount?) -> ()
    private var onInitialSessionStateChanged: (Bool,LCSession) -> ()
    private var onSendMessageStateChange: (LCSendMessageEnum,LCMessage?,String?,String?) -> ()
    private var onRestartScripting: ([LCButtonAction]) -> ()
    
    public init(
        onReceiveMessage: @escaping (LCMessage)->(),
        onGotDetailConversation: @escaping ([LCMessage]) -> (),
        onInitSDKStateChange: @escaping (LCInitialEnum,String)->(),
        onAuthstateChanged:@escaping (Bool,String,LCAccount?) -> (),
        onInitialSessionStateChanged:@escaping (Bool,LCSession) -> (),
        onSendMessageStateChange:@escaping (LCSendMessageEnum,LCMessage?,String?,String?) -> (),
        onRestartScripting: @escaping ([LCButtonAction]) -> ()
    ) {
        self.onReceiveMessage = onReceiveMessage
        self.onGotDetailConversation = onGotDetailConversation
        self.onInitSDKStateChange = onInitSDKStateChange
        self.onAuthstateChanged = onAuthstateChanged
        self.onInitialSessionStateChanged = onInitialSessionStateChanged
        self.onSendMessageStateChange = onSendMessageStateChange
        self.onRestartScripting = onRestartScripting
    }
    
    func onReceiveMessage(lcMessage: LCMessage) {
        self.onReceiveMessage(lcMessage)
    }
    
    func onGotDetailConversation(messages: [LCMessage]) {
        self.onGotDetailConversation(messages)
    }
    
    func onInitSDKStateChange(state: LCInitialEnum, message: String) {
        self.onInitSDKStateChange(state,message)
    }
    
    func onAuthstateChanged(success: Bool, message: String, lcAccount: LCAccount?) {
        self.onAuthstateChanged(success,message,lcAccount)
    }
    
    func onInitialSessionStateChanged(success: Bool, lcSession: LCSession) {
        self.onInitialSessionStateChanged(success,lcSession)
    }
    
    func onSendMessageStateChange(state: LCSendMessageEnum, message: LCMessage?, errorMessage: String?,mappingId: String?) {
        self.onSendMessageStateChange(state,message,errorMessage,mappingId)
    }
    
    func onRestartScripting(buttonActions: [LCButtonAction]) {
        self.onRestartScripting(buttonActions)
    }
}

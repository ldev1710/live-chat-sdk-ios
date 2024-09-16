//
//  LCProtocol.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

protocol LCProtocol {
    func onReceiveMessage(lcMessage: LCMessage)
    func onInitSDKStateChange(state: LCInitialEnum, message: String)
    func onAuthstateChanged(success: Bool, message: String, lcAccount:LCAccount?)
    func onInitialSessionStateChanged(success: Bool, lcSession: LCSession)
    func onGotDetailConversation(messages: [LCMessage])
    func onSendMessageStateChange(state: LCSendMessageEnum, message: LCMessage?, errorMessage: String?,mappingId: String?)
}

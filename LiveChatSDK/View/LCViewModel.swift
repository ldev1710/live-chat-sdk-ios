//
//  LCViewModel.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 30/07/2024.
//

import Foundation

class LChatViewModel: ObservableObject {
    @Published var messages: [LCMessage] = []
    @Published var newMessageText: String = ""
    private var lcUser: LCUser!
    private var lcSession: LCSession!
    
    init() {
        let currSessionId = UserDefaults.standard.string(forKey: "currSessionId")
        let currVisitorJid = UserDefaults.standard.string(forKey: "currVisitorJid")
        lcSession = LCSession(sessionId: currSessionId!, visitorJid: currVisitorJid!)
        let standard = UserDefaults.standard
        let fullName = standard.string(forKey: "fullName")
        let email = standard.string(forKey: "email")
        let phone = standard.string(forKey: "phone")
        let deviceName = standard.string(forKey: "deviceName")
        lcUser = LCUser(fullName: fullName!, email: email!, phone: phone!, deviceName: deviceName!)
    }
    
    func sendMessage() {
        LiveChatFactory.sendMessage(lcUser: lcUser, message: LCMessageSend(content: newMessageText, lcSession: lcSession))
        newMessageText = ""
    }
    
    func sendFile(fileURL: [URL]) {
        LiveChatFactory.sendFileMessage(paths: fileURL, lcUser: lcUser, lcSession: lcSession)
    }
}

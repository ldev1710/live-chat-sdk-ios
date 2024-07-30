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
    
    func sendMessage() {
        LiveChatFactory.sendMessage(message: LCMessageSend(content: newMessageText))
        newMessageText = ""
    }
    
    func sendFile(fileURL: [URL]) {
        LiveChatFactory.sendFileMessage(paths: fileURL)
    }
}

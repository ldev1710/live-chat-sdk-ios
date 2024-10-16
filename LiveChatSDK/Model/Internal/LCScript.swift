//
//  LCScript.swift
//  LiveChatSDK
//
//  Created by Luong Dien on 16/10/24.
//

public class LCScript {
    
    init(id: String, name: String, nextAction: String, buttonAction: [LCButtonAction]) {
        self.id = id
        self.name = name
        self.nextAction = nextAction
        self.buttonAction = buttonAction
    }
    
    var id: String
    var name: String
    var nextAction: String
    var buttonAction: [LCButtonAction]
}

public class LCButtonAction {
    init(textSend: String, nextId: String) {
        self.textSend = textSend
        self.nextId = nextId
    }
    
    var textSend: String
    var nextId: String
}

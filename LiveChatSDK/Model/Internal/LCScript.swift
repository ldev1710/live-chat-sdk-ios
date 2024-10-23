//
//  LCScript.swift
//  LiveChatSDK
//
//  Created by Luong Dien on 16/10/24.
//

public class LCScript: ObservableObject {
    
    init(id: String, name: String, nextAction: String,answers: [LCAnswer], buttonAction: [LCButtonAction]) {
        self.id = id
        self.name = name
        self.nextAction = nextAction
        self.buttonAction = buttonAction
        self.answers = answers
    }
    
    var id: String
    var name: String
    var nextAction: String
    var answers: [LCAnswer]
    var buttonAction: [LCButtonAction]
    
    public func toString() -> String {
        return "LCScript(id: \(id), name: \(name), nextAction: \(nextAction), answers: \(answers), buttonAction: \(buttonAction))"
    }
}

public class LCButtonAction: Hashable {
    init(textSend: String, nextId: String) {
        self.textSend = textSend
        self.nextId = nextId
    }
    
    var textSend: String
    var nextId: String
    
    // Conform to Equatable
    public static func == (lhs: LCButtonAction, rhs: LCButtonAction) -> Bool {
        return lhs.textSend == rhs.textSend && lhs.nextId == rhs.nextId
    }
    
    // Conform to Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(textSend)
        hasher.combine(nextId)
    }
}

public class LCAnswer {
    var type: String
    var value: String
    
    init(type: String, value: String) {
        self.type = type
        self.value = value
    }
    
}

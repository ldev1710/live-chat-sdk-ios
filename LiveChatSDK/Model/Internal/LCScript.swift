//
//  LCScript.swift
//  LiveChatSDK
//
//  Created by Luong Dien on 16/10/24.
//

public class LCScript: ObservableObject {
    
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
    
    func toString() -> String {
        return "LCScript(id: \(id), name: \(name), nextAction: \(nextAction), buttonAction: \(buttonAction))"
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

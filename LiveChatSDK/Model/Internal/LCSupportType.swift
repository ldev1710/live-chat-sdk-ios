//
//  LCSupportType.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

public class LCSupportType:Identifiable {
    public var id: String
    public var name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

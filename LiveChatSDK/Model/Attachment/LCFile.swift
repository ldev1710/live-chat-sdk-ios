//
//  LCFile.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 22/07/2024.
//

import Foundation

public class LCFile :Identifiable {
    public var fileName: String
    public var fileExtension: String
    
    public init(fileName: String, fileExtension: String) {
        self.fileName = fileName
        self.fileExtension = fileExtension
    }
}

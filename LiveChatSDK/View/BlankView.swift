//
//  File.swift
//  
//
//  Created by Dev App Mitek on 30/07/2024.
//

import Foundation
import SwiftUI

struct LCBlankView: View {
    var body: some View {
        VStack {
            Text("Please set user session, through LiveChatFactory.setUserSession function!")
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
        }
    }
}

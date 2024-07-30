//
//  ChatViewController.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 30/07/2024.
//

import Foundation
import UIKit
import SwiftUI

class LChatViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let chatView = LChatView()
        let hostingController = UIHostingController(rootView: chatView)
        addChild(hostingController)
        hostingController.view.frame = view.frame
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}

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
    
    let onTapBack: () -> Void
    
    init(onTapBack: @escaping () -> Void) {
        self.onTapBack = onTapBack
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let chatView = LChatView(onTapBack: onTapBack)
        let hostingController = UIHostingController(rootView: chatView)
        addChild(hostingController)
        hostingController.view.frame = view.frame
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}

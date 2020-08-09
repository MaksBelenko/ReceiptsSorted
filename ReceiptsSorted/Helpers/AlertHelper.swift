//
//  AlertFactory.swift
//  ReceiptsSorted
//
//  Created by Maksim on 15/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit.UIAlertController


class AlertHelper {
    
    private let alertController: UIAlertController
    
    init(alertController: UIAlertController, actions: [UIAlertAction]) {
        self.alertController = alertController
        actions.forEach { alertController.addAction($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func show(for controller: UIViewController) {
        controller.present(alertController, animated: true, completion: nil)
    }
}

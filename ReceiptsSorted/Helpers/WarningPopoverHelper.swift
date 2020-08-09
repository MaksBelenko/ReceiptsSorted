//
//  CurrencyWarningPopover.swift
//  ReceiptsSorted
//
//  Created by Maksim on 09/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class WarningPopoverHelper {
    
    
    func createWarningPopover(for button: UIButton, ofSize size: CGSize) -> UIViewController {
        let popController = WarningViewController()  //tableViewController.popoverPresentationController
        
        popController.preferredContentSize = size
        
        popController.modalPresentationStyle = .popover
        
        popController.popoverPresentationController?.sourceView = button
        popController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: button.frame.size.width, height: button.frame.size.height)
        
        popController.popoverPresentationController?.permittedArrowDirections = .up
        
        return popController
    }
}


class WarningViewController: UIViewController {
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.font = .arial(ofSize: 14)
        label.text = "Warning: you have pending\nreceipts in other currencies"
        label.numberOfLines = 0
        return label
    }()
    
    
    override func viewDidLoad() {
        view.addSubview(warningLabel)
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 5).isActive = true
        warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}

//
//  AddButtonAnimations.swift
//  ReceiptsSorted
//
//  Created by Maksim on 04/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class AddButtonAnimations {
    
    func startAnimatingPressActions(for button: UIButton) {
        button.addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        button.addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
        
        //Action when button is actualy pressed
//        button.addTarget(self, action: #selector(ViewController.addButtonPressed), for: .touchUpInside)
    }
    
    @objc private func animateDown(sender: UIButton) {
        animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9))
    }
    
    @objc private func animateUp(sender: UIButton) {
        animate(sender, transform: .identity)
    }
    
    private func animate(_ button: UIButton, transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.1, animations: {
                            button.transform = transform
                        }, completion: nil)
    }
}

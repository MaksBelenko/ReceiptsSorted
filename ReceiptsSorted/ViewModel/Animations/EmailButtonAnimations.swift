//
//  EmailButtonAnimations.swift
//  ReceiptsSorted
//
//  Created by Maksim on 31/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class EmailButtonAnimations {
    
    var buttonOpenned = false
    private var animationDuration: Double = 0.3
    
    var button1: UIButton = {
        let button = UIButton(type: .system)

        button.frame = CGRect(x: 0, y: 50, width: 100, height: 30)
        button.backgroundColor = UIColor.flatOrange  //orange Flat UI
        button.setTitle("test1", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = button.frame.size.height / 2

//        button.isUserInteractionEnabled = true
//        button.isExclusiveTouch = true

        return button
    }()
    
    var button2: UIButton = {
        let button = UIButton(type: .system)

        button.frame = CGRect(x: 0, y: 100, width: 100, height: 30)
        button.backgroundColor = .flatOrange  //orange Flat UI
        button.setTitle("test2", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = button.frame.size.height / 2

//        button.isUserInteractionEnabled = true
//        button.isExclusiveTouch = true

        return button
    }()
    
    
//    init() {
//        button1 = createButton(withTitle: "test")
//    }
//
//
    func createButton(withTitle buttonTitle: String) -> UIButton {
        let button = UIButton(type: .system)

        button.frame = CGRect(x: 0, y: 50, width: 100, height: 30)
        button.backgroundColor = UIColor(rgb: 0xEDB200)  //orange Flat UI
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = button.frame.size.height / 2

//        button.isUserInteractionEnabled = true
//        button.isExclusiveTouch = true

        return button
    }
    
    
    
    
    
    
    
    func animate(button: UIButton) {
        if (buttonOpenned == false) {
            animateOpenning(of: button)
        } else {
            animateClosing(of: button)
        }
        
        buttonOpenned = !buttonOpenned
    }
    
    
    
    
    private func animateOpenning(of button: UIButton) {
        button.setBackgroundImage(UIImage(), for: .normal)
        button.setTitle("✕", for: .normal)
//        button.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        button.backgroundColor = UIColor(rgb: 0x0B253E)
        button.layer.cornerRadius = button.frame.size.height/2
        
//        UIView.animate(withDuration: animationDuration) {
//            button.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
//        }
        
        
        
        button.addSubview(button1)
        button.addSubview(button2)
        
    }
    
    
    private func animateClosing(of button: UIButton) {
        button.setBackgroundImage(UIImage(systemName: "envelope.circle"), for: .normal)
        
//        UIView.animate(withDuration: animationDuration) {
//            button.transform = CGAffineTransform.identity
//        }
        
        button1.removeFromSuperview()
        button2.removeFromSuperview()
    }
}

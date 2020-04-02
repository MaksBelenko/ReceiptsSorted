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
    
    private var button: UIButton!
    private var container: UIView!
    private var heightConstraint: NSLayoutConstraint!
    private var widthConstraint: NSLayoutConstraint!

    private let buttonAnimations = AddButtonAnimations()
    private var buttonPending: UIButton!
    private var buttonSelect: UIButton!
    private var circleView: UIView!
    
    
    
    
    //MARK: - Initialisation
    
    init(button: UIButton, container: UIView, heightConstraint: NSLayoutConstraint, widthConstraint: NSLayoutConstraint) {
        self.button = button
        self.container = container
        self.heightConstraint = heightConstraint
        self.widthConstraint = widthConstraint
        
        buttonPending = createEmailSubviewButton(withTitle: "All Pending", yOffset: 55, width: 160)
        buttonSelect = createEmailSubviewButton(withTitle: "Select", yOffset: 110, width: 100)
        circleView = createCircleButtonView()
        
        container.insertSubview(circleView, at: 0)
        container.addSubview(buttonPending)
        container.addSubview(buttonSelect)
    }
    
    
    
    //MARK: - Public animation methods
    
    /**
     Animates openning or closing of the email button
     */
    func animate() {
        if (buttonOpenned == false) {
            animateOpenning()
        } else {
            animateClosing(of: button)
        }
        
        buttonOpenned = !buttonOpenned
    }
    
    
    /**
     Closes the email popup if it is openned
     */
    func closeIfOpenned() {
        if (buttonOpenned == true) {
            animate()
        }
    }
    
    
    
    
    //MARK: - Private animation methods
    
    /**
     Animation for the openning the email button animation
     */
    private func animateOpenning() {
        button.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        changeContainerConstraints(width: 140, height: 125)
 
        UIView.animate(withDuration: animationDuration) {
            self.container.superview?.layoutIfNeeded()
            self.container.backgroundColor = UIColor(rgb: 0x213345).withAlphaComponent(0.8)
            self.button.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveLinear, animations: {
            self.buttonPending.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveLinear, animations: {
            self.buttonSelect.alpha = 1
        }, completion: nil)
        
    }
    
    
    /**
     Animation for the closing the email button animation
     */
    private func animateClosing(of button: UIButton) {
        button.setBackgroundImage(UIImage(systemName: "envelope.circle"), for: .normal)
        changeContainerConstraints(width: 20, height: 20)
        
        UIView.animate(withDuration: 0.2) {
            self.buttonSelect.alpha = 0
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveLinear, animations: {
            self.buttonPending.alpha = 0
        }, completion: nil)
        
        
        
        UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveLinear, animations: {
            self.container.superview?.layoutIfNeeded()
            self.container.backgroundColor = UIColor.wetAsphalt.withAlphaComponent(1)
            self.button.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    
    
    
    
    
    //MARK: - Constraints
    
    /**
     Changes constraints for the Email Container UIView;
     Deactivates all constraint and activates new constrint
     - Parameter width: New width
     - Parameter height: New height
     */
    private func changeContainerConstraints(width: CGFloat, height: CGFloat) {
        NSLayoutConstraint.deactivate([heightConstraint, widthConstraint])
        heightConstraint.constant = height
        widthConstraint.constant  = width
        NSLayoutConstraint.activate([heightConstraint, widthConstraint])
    }
    


    //MARK: - Elements creation for the popup
    
    /**
     Creates subview button to be used in Email Container UIView
     - Parameter buttonTitle: Title of the button
     - Parameter yOffset: Offset of the button in Y direction
     - Parameter width: Width of the button
     */
    private func createEmailSubviewButton(withTitle buttonTitle: String, yOffset: Int, width: Int) -> UIButton {
        let button = UIButton(type: .system)

        button.frame = CGRect(x: 8, y: yOffset, width: width, height: 40)
        button.backgroundColor = UIColor.flatOrange //orange Flat UI
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = button.frame.size.height / 2

        buttonAnimations.startAnimatingPressActions(for: button)
        
        button.alpha = 0 // Make it invisible first
         
        return button
    }
    
    
    /**
     Creates circle UIView to put behind email/cross button
     */
    private func createCircleButtonView() -> UIView {
        let circleView = UIView(frame: CGRect(x: 8, y: 8, width: button.frame.size.width, height: button.frame.size.height))
        circleView.backgroundColor = UIColor.wetAsphalt
        circleView.layer.cornerRadius = circleView.frame.size.height / 2
        return circleView
    }
}

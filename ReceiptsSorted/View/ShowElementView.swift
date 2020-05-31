//
//  ShowElementView.swift
//  ReceiptsSorted
//
//  Created by Maksim on 31/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class ShowElementView: UIView {

//    var showArea: CGRect!
    var borderWidth: CGFloat!
    var shapeView: UIView!
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    
    // MARK: - Initialisation
    init(showArea: CGRect, /*text: NSMutableAttributedString,*/ frame: CGRect) {
        super.init(frame: frame)
        
        borderWidth = frame.height
        createView(showArea: showArea)
        createText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Views Creation
    private func createView(showArea: CGRect) {
        shapeView = UIView(frame: showArea)
        shapeView.frame = shapeView.frame.insetBy(dx: -borderWidth, dy: -borderWidth);
        shapeView.backgroundColor = .clear
        shapeView.layer.borderWidth = borderWidth
        shapeView.layer.cornerRadius = borderWidth + showArea.height/4
        shapeView.layer.borderColor = UIColor.wetAsphalt.withAlphaComponent(0.75).cgColor
        
        self.addSubview(shapeView)
//        layoutIfNeeded()
    }
    
    private func createText() {
        var attrText = setupLabel(inBold: "Pending", text: "tab shows payments which were paid by you but the company has not paid you back yet.")
        let attrText2 = setupLabel(inBold: "\n\nReceived", text: "tab shows the received from the company payments.")
        attrText.append(attrText2)
        infoLabel.attributedText = attrText
        
        
        self.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.topAnchor.constraint(equalTo: shapeView.centerYAnchor, constant: 50).isActive = true
        infoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        infoLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true

    }
    
    
    
    // MARK: - Helpers
    private func setupLabel(inBold boldText: String, text: String) -> NSMutableAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(boldText) ",attributes:
                                [NSAttributedString.Key.font : UIFont(name: "Arial-BoldMT", size: 18) ?? UIFont.boldSystemFont(ofSize: 19),
                                 NSAttributedString.Key.foregroundColor : UIColor.white])
        
        attributedTitle.append(NSAttributedString(string: text, attributes:
                                [NSAttributedString.Key.font : UIFont(name: "Arial", size: 18) ?? UIFont.systemFont(ofSize: 19),
                                 NSAttributedString.Key.foregroundColor : UIColor.white]))
        
        return attributedTitle
//        setAttributedTitle(attributedTitle, for: .normal)
    }
    
    
    
    private func createBeatingBorder(showArea: CGRect) {
        let beatingView = UIView(frame: showArea)
        beatingView.frame = beatingView.frame.insetBy(dx: -5, dy: -5);
        beatingView.backgroundColor = .clear
        beatingView.layer.borderWidth = 5
        beatingView.layer.cornerRadius = borderWidth/4
        beatingView.layer.borderColor = UIColor.white.cgColor

        self.addSubview(beatingView)
        
        DispatchQueue.main.async {
//            let widthAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.borderWidth))
//            widthAnimation.fromValue = 10
//            widthAnimation.toValue = 20
//            widthAnimation.duration = 2
//            widthAnimation.repeatCount = 1
//            beatingView.layer.add(widthAnimation, forKey: "borderWidth")
        }
        
    }
    

}

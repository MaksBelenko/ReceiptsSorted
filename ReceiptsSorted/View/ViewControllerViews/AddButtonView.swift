//
//  AddButtonView.swift
//  ReceiptsSorted
//
//  Created by Maksim on 24/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class AddButtonView: UIView {
    
    let buttonAnimations = AddButtonAnimations()
    var addButton: UIButton!
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: CGRect())
        
        configureAddButton()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func configureAddButton() {
        addButton = UIButton(type: .system)
        addButton.backgroundColor = UIColor.flatOrange //orange Flat UI
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 45)
        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        addButton.setTitleColor(.white, for: .normal)
//        addButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        addButton.layer.applyShadow(color: .flatOrange, alpha: 0.5, x: 1, y: 2, blur: 4)
        addButton.layer.cornerRadius = 18
        addButton.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
        buttonAnimations.startAnimatingPressActions(for: addButton)
    }
    
    
    
    private func configureView() {
        /* Adding Transform Layer to enable 3D animation*/
        var perspective = CATransform3DIdentity
        perspective.m34 = -1 / 1000
        let transformLayer = CATransformLayer()
        transformLayer.transform = perspective

        transformLayer.addSublayer(addButton.layer)
        layer.addSublayer(transformLayer)
        
        /* Add Button to button view and adjust corner radius*/
        addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        addButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        addButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        addButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

}

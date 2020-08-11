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
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.flatOrange //orange Flat UI
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 45)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        button.setTitleColor(.white, for: .normal)
//        button.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        button.layer.applyShadow(color: .flatOrange, alpha: 0.5, x: 1, y: 2, blur: 4)
        button.layer.cornerRadius = 16
        button.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
        buttonAnimations.startAnimatingPressActions(for: button)
        
        return button
    }()
    
    
    
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: CGRect())
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Configure UI
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


// MARK: - TraitCollection
extension AddButtonView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                let flatOrangeCgColor = UIColor.flatOrange.cgColor
                addButton.layer.shadowColor = flatOrangeCgColor
            }
        }
    }
}

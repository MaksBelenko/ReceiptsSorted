//
//  PaymentSelectionButtonView.swift
//  ReceiptsSorted
//
//  Created by Maksim on 18/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class PaymentSelectionButtonView: UIButton {
    
    let buttonAnimations = AddButtonAnimations()
    
    init(text: String, _ target: Any?, action: Selector) {
        super.init(frame: CGRect())
        
        self.backgroundColor = UIColor.flatOrange //orange Flat UI
        self.setTitle(text, for: .normal)
        self.titleLabel?.font = UIFont.arial(ofSize: 16)
        self.titleLabel?.textAlignment = .center
        self.setTitleColor(.white, for: .normal)
        self.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        self.layer.applyShadow(color: .flatOrange, alpha: 0.5, x: 1, y: 2, blur: 4)
        self.layer.cornerRadius = 18
        buttonAnimations.startAnimatingPressActions(for: self)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  ShowElementView.swift
//  ReceiptsSorted
//
//  Created by Maksim on 31/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class ShowElementView: UIView, IPresentationView {
    
    weak var delegate: OnboardingButtonProtocol?
    
    var shapeView: UIView!
    
    private var addCornerRadius: Bool = true
    private var borderWidth: CGFloat!
    private let buttonAnimations = AddButtonAnimations()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    
    let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Next →", for: .normal)
        button.titleLabel?.font = UIFont.arialBold(ofSize: 19)
        button.backgroundColor = .flatOrange
        button.layer.cornerRadius = 10
        button.layer.applyShadow(color: .flatOrange, alpha: 0.5, x: 1, y: 4, blur: 6)
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.arial(ofSize: 19)
        return button
    }()

    
    
    // MARK: - Initialisation
    init(showArea: CGRect, text: NSMutableAttributedString, frame: CGRect, addCornerRadius: Bool) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        self.addCornerRadius = addCornerRadius
        
        borderWidth = frame.height*2
        createView(showArea: showArea)
        createText(text: text, showArea: showArea)
        setupNextButton()
        setupBackButton()
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
        shapeView.layer.borderColor = UIColor.wetAsphalt.withAlphaComponent(0.8).cgColor
        
        if addCornerRadius {
            shapeView.layer.cornerRadius = borderWidth + showArea.height/4 + 2        }
        
        self.addSubview(shapeView)
    }
    
    private func createText(text: NSAttributedString, showArea: CGRect) {
        infoLabel.attributedText = text
        
        self.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.topAnchor.constraint(equalTo: shapeView.centerYAnchor, constant: showArea.size.height/2 + 30).isActive = true
        infoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        infoLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true

    }
    
    private func setupNextButton() {
        self.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        buttonAnimations.startAnimatingPressActions(for: nextButton)
    }
    
    private func setupBackButton() {
        self.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        backButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        buttonAnimations.startAnimatingPressActions(for: backButton)
    }
    
    
    // MARK: - Press Actions
    @objc private func nextButtonPressed() {
        delegate?.showNextPage()
    }
    
    @objc private func backButtonPressed() {
        delegate?.showPreviousPage()
    }

}

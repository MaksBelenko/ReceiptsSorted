//
//  WelcomeView.swift
//  ReceiptsSorted
//
//  Created by Maksim on 01/06/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class WelcomeView: UIView, IPresentationView {
    
    weak var delegate: OnboardingProtocol?
    
    private let titleText = "Welcome\nto\nWorkReceipts"
    private let sloganText = "\n\nAn app that allows you to\npainlessly track your receipts"
    private let hypeText = "Let's do a quick tour!"
    
    
    private let textHelper = TextHelper()
    private let buttonAnimations = AddButtonAnimations()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Next →", for: .normal)
        button.titleLabel?.font = UIFont.arialBold(ofSize: 19)
        button.backgroundColor = .flatOrange
        button.layer.cornerRadius = 10
        button.layer.applyShadow(color: .flatOrange, alpha: 0.5, x: 1, y: 4, blur: 6)
        return button
    }()
    
    
    
    // MARK: - Initialisation
    override init(frame: CGRect) {
        super.init(frame: frame)
        showWelcomePage(frame: frame)
        setupText()
        setupNextButton()
        setupBottomText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Setup
    private func showWelcomePage(frame: CGRect) {
        let welcomeView = UIView(frame: frame)
        welcomeView.backgroundColor = UIColor.wetAsphalt.withAlphaComponent(0.8)
        self.addSubview(welcomeView)
    }
    
    private func setupText() {
        let welcomePageText = textHelper.create(text: titleText, bold: true, fontSize: 40)
        welcomePageText.append(textHelper.create(text: sloganText, bold: true, fontSize: 18))
        let welcomeLabel = UILabel()
        welcomeLabel.attributedText = welcomePageText
        welcomeLabel.numberOfLines = 0
        
        self.addSubview(welcomeLabel)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        welcomeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        welcomeLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
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
    
    
    private func setupBottomText() {
        let bottomLabel = UILabel()
        bottomLabel.attributedText = textHelper.create(text: hypeText, bold: true, fontSize: 20)
        bottomLabel.textAlignment = .center
        
        self.addSubview(bottomLabel)
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -50).isActive = true
        bottomLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        bottomLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
    }
    
    
    // MARK: - Press Actions
    @objc private func nextButtonPressed() {
        delegate?.showNextPage()
    }
}

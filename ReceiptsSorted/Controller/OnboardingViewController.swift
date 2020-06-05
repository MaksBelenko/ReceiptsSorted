//
//  OnboardingViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 31/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

protocol OnboardingButtonProtocol: AnyObject {
    func showNextPage()
    func showPreviousPage()
}

protocol IPresentationView: UIView {
    var delegate: OnboardingButtonProtocol? { get set }
}


class OnboardingViewController: UIViewController {

    private var showWelcomePage = true
    private var addCornerRadius = true
    
    private let userChecker = UserChecker()
    
    private var elements: [OnboardingInfo] = []
    private var showingView: IPresentationView?
    private var allViews: [IPresentationView]! = []
    private var pageNumber = 0

    
    // MARK: - Initialisation
    init(showWelcomePage: Bool = true, addCornerRadius: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        self.showWelcomePage = showWelcomePage
        self.addCornerRadius = addCornerRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateSequenceOfViews()
        showView(for: pageNumber)
    }
    
    
    
    private func generateSequenceOfViews() {
        if showWelcomePage {
            allViews.append(WelcomeView(frame: view.frame))
        }
        
        for info in elements {
            allViews.append(ShowElementView(showArea: info.showRect,
                                            text: info.text,
                                            frame: view.frame,
                                            addCornerRadius: addCornerRadius))
        }
        
    }
    
    
    /**
     Add onboarding info of frame and text to show in onboarding
     - Parameter info: Info containing frame and text
     */
    func add(info: OnboardingInfo) {
        elements.append(info)
    }
}



extension OnboardingViewController: OnboardingButtonProtocol {
    
    func showNextPage() {
        pageNumber += 1
        
        if pageNumber == allViews.count {
            userChecker.setIsOldUser()
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        showView(for: pageNumber)
    }
    
    func showPreviousPage() {
        
        if pageNumber == 0 {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        pageNumber -= 1
        showView(for: pageNumber)
    }
    
    
    
    private func showView(for pageNum: Int) {
        showingView?.delegate = nil
        showingView?.removeFromSuperview()
        
        showingView = allViews[pageNum]
        showingView?.delegate = self
        
        if pageNum == allViews.count - 1 {
            guard let lastView = showingView as? ShowElementView else { return }
            lastView.nextButton.setTitle("Done!", for: .normal)
            lastView.nextButton.backgroundColor = .clear
            lastView.nextButton.layer.removeShadow()
        }
        
        
        
        view.addSubview(showingView!)
    }
    
    
}

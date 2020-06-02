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

    private var elements: [OnboardingInfo] = []
    private var showingView: IPresentationView?
    private var allViews: [IPresentationView]! = []
    private var pageNumber = 0

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateSequenceOfViews()
        showView(for: pageNumber)
    }
    
    
    
    private func generateSequenceOfViews() {
        allViews.append(WelcomeView(frame: view.frame))
        
        for info in elements {
            allViews.append(ShowElementView(showArea: info.showRect,
                                            text: info.text,
                                            frame: view.frame))
        }
        
    }
    
    func add(info: OnboardingInfo) {
        elements.append(info)
    }
}



extension OnboardingViewController: OnboardingButtonProtocol {
    
    func showNextPage() {
        pageNumber += 1
        
        if pageNumber == allViews.count {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        showView(for: pageNumber)
    }
    
    func showPreviousPage() {
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

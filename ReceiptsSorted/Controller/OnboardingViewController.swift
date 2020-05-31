//
//  OnboardingViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 31/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    var showingView: ShowElementView!
    var elementsRect: [CGRect] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        let rect = elementsRect.first!
        showingView = ShowElementView(showArea: rect, frame: view.frame)

        view.addSubview(showingView)
    }
    

}

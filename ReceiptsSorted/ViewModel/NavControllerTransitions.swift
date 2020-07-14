//
//  NavControllerTransitions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 14/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

/// Class responsible for Navigation controller transitions
class NavControllerTransitions: NSObject {

    private let circularTransition = CircularTransition()
    private let animationCentre: CGPoint
    
    init(animationCentre: CGPoint) {
        self.animationCentre = animationCentre
    }
    
}


// MARK: - UINavigationControllerDelegate, UIViewControllerTransitioningDelegate
extension NavControllerTransitions: UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if ( (toVC is CameraViewController && fromVC is ViewController) ||
            (toVC is ViewController && fromVC is CameraViewController)) {
            
            circularTransition.transitionMode = (operation == .push) ? .present : .pop
            circularTransition.startingPoint = animationCentre
            return circularTransition
        }

        return nil
    }
}

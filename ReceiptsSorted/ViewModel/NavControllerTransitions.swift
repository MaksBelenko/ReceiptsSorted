//
//  NavControllerTransitions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 14/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class NavControllerTransitions: NSObject {

    private let circularTransition = CircularTransition()
    private let animationCentre: CGPoint
    
    init(animationCentre: CGPoint) {
        self.animationCentre = animationCentre
    }
    
}



extension NavControllerTransitions: UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        // Perform custom animation only if CameraViewController
        guard let _ = toVC as? CameraViewController else { return nil }

        circularTransition.transitionMode = (operation == .push) ? .present : .pop
        circularTransition.startingPoint = animationCentre

        return circularTransition
    }
}

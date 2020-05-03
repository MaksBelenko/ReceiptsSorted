//
//  CircularTransition.swift
//  ReceiptsSorted
//
//  Created by Maksim on 30/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit

class CircularTransition: NSObject  {

    var duration: TimeInterval = 0.4
    
    enum TransitionMode {
        case present, dismiss, pop
    }
    
    weak var context: UIViewControllerContextTransitioning?
    var transitionMode: TransitionMode = .present
    var startingPoint = CGPoint.zero
}
    


// MARK: - UIViewControllerAnimatedTransitioning

extension CircularTransition: UIViewControllerAnimatedTransitioning {
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        context = transitionContext
        let containerView = transitionContext.containerView
     
        if transitionMode == .present {
            if let presentedView = transitionContext.view(forKey: .to) {
                containerView.addSubview(presentedView)
                showMaskAnimation(for: presentedView, withAnimationFor: .present)
            }
        } else {
            let transitionModeKey = (transitionMode == .pop) ? UITransitionContextViewKey.to : UITransitionContextViewKey.from
            
            if let returningView = transitionContext.view(forKey: transitionModeKey) {
                showMaskAnimation(for: returningView, withAnimationFor: .dismiss)
            }
        }
    }

    
    
    // MARK: - CAShapeLayer mask animation
    
    /**
     Creates and animates mask for the transition animation
     - Parameter view: UIView that will be shown
     - Paramter tMode: Transition mode
     */
    private func showMaskAnimation(for view: UIView, withAnimationFor tMode: TransitionMode) {
        let rect = CGRect(x: startingPoint.x, y: startingPoint.y,
                          width: 1, height: 1)

        let circleMaskPathInitial = UIBezierPath(roundedRect: rect, cornerRadius: rect.height/6)

        let viewHeight = view.bounds.height
        let extremePoint = CGPoint(x: startingPoint.x, y: startingPoint.y - viewHeight)
        let radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        let newRect = rect.insetBy(dx: -radius, dy: -radius)
        let circleMaskPathFinal = UIBezierPath(roundedRect: newRect, cornerRadius: newRect.height/6)

        let maskLayer = CAShapeLayer()
        maskLayer.path = (tMode == .present) ? circleMaskPathFinal.cgPath : circleMaskPathInitial.cgPath
        view.layer.mask = maskLayer

        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.duration = duration
        maskLayerAnimation.fromValue = (tMode == .present) ? circleMaskPathInitial.cgPath : circleMaskPathFinal.cgPath
        maskLayerAnimation.toValue = (tMode == .present) ? circleMaskPathFinal.cgPath : circleMaskPathInitial.cgPath
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    
}




// MARK: - CAAnimationDelegate
extension CircularTransition: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        context?.completeTransition(true)
    }
}

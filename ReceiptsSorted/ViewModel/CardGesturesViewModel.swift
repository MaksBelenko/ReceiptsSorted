//
//  CardGesturesViewModel.swift
//  ReceiptsSorted
//
//  Created by Maksim on 24/02/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class CardGestures {
    
    
    var visualEffectView : UIVisualEffectView!  //For blur
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    
//    init(cardView:)
//    
//    
//    
//    /**
//    Starts an interactive Card transition
//
//    - Parameter state: The card state which is either "Expanded" or "Collapsed".
//    - Parameter duration: Duration of the animation.
//    */
//    func startInteractiveTransition (forState state: CardState, duration: TimeInterval) {
//        if runningAnimations.isEmpty {
//            animateTransitionIfNeeded(with: state, for: duration, withDampingRatio: 0.8)
//        }
//
//        for animator in runningAnimations {
//            animator.pauseAnimation()
//            animationProgressWhenInterrupted = animator.fractionComplete
//        }
//    }
//
//
//    /**
//    Updates animators' fraction of the animation that is completed
//
//    - Parameter fractionCompleted: fraction of the animation calculated beforehand.
//    */
//    func updateInteractiveTransition (fractionCompleted: CGFloat) {
//       for animator in runningAnimations {
//           animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
//       }
//        
//    }
//
//
//    /**
//    Continues all remaining animations
//    */
//    func continueInteractiveTransition() {
//        for animator in runningAnimations {
//            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
//        }
//    }
//    
//    /**
//    Stops animation and goes to start of the animation
//    */
//    func stopAndGoToStartPositionInteractiveTransition() {
//        for animator in runningAnimations {
//            animator.stopAnimation(false)
//            animator.finishAnimation(at: .start)
//        }
//        self.runningAnimations.removeAll()
//        
//        cardVisible = !cardVisible
//    }
//    
//    
//    
//    /**
//    Creates array of animations and starts them
//
//    - Parameter state: The card state which is either ".Expanded" or ".Collapsed".
//    - Parameter duration: Duration of the animation.
//    */
//    func animateTransitionIfNeeded (with state: CardState, for duration: TimeInterval, withDampingRatio dumpingRatio: CGFloat) {
//
//        /* Size animation */
//        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dumpingRatio) {
//            switch state {
//            case .Expanded:
//                self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
//
//            case .Collapsed:
//                self.cardViewController.view.frame.origin.y = self.cardStartPointY
//            }
//        }
//
//        frameAnimator.addCompletion { _ in
//            cardVisible = !cardVisible
//            self.runningAnimations.removeAll()
//            //self.cardViewController.tblView.isUserInteractionEnabled = true
//        }
//
//        frameAnimator.startAnimation()
//        runningAnimations.append(frameAnimator)
//
//        
//        /* Blur animation*/
//        let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dumpingRatio) {
//            switch state {
//            case .Expanded:
//                self.visualEffectView.effect = UIBlurEffect(style: .dark)
//            case .Collapsed:
//                self.visualEffectView.effect = nil
//            }
//        }
//
//        blurAnimator.startAnimation()
//        runningAnimations.append(blurAnimator)
//        
//        
//        /* Add Button Opacity animation*/
//        let buttonOpacityAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dumpingRatio) {
//            switch state {
//            case .Expanded:
//                self.addButton.alpha = 0
//            case .Collapsed:
//                self.addButton.alpha = 1
//            }
//        }
//
//        buttonOpacityAnimator.startAnimation()
//        runningAnimations.append(buttonOpacityAnimator)
//        
//    }
//    
    
}

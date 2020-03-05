//
//  CardAnimations.swift
//  ReceiptsSorted
//
//  Created by Maksim on 04/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class CardAnimations {
    
    var cardHeight: CGFloat!
    var cardStartPointY: CGFloat!
    var mainViewHeight: CGFloat!
    var cardViewController : CardViewController?
    var addButton: UIButton?
    
    var lastFraction: CGFloat = 0.0
    var visualEffectView : UIVisualEffectView?  //For blur
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    
    init (mainViewHeight: CGFloat, cardViewController: CardViewController?, addButton: UIButton?, visualEffectView: UIVisualEffectView?){
        cardStartPointY = mainViewHeight / 2
        cardHeight = mainViewHeight * 19/20
        self.mainViewHeight = mainViewHeight
        self.cardViewController = cardViewController
        self.addButton = addButton
        self.visualEffectView = visualEffectView
    }
    
    
    
    @objc func handleCardTap(recogniser: UITapGestureRecognizer) {
        animateTransitionIfNeeded(with: nextState, for: 0.7, withDampingRatio: 0.8)
    }

    
     @objc func handleCardPan (recogniser: UIPanGestureRecognizer) {
            
            switch recogniser.state{
            case .began:
                startInteractiveTransition(forState: nextState, duration: 0.6)
                
            case .changed:
                let translation = recogniser.translation(in: recogniser.view)
                fractionComplete = translation.y / (cardStartPointY - mainViewHeight + cardHeight)
                fractionComplete = cardVisible ? fractionComplete : -fractionComplete

                lastFraction = fractionComplete
                updateInteractiveTransition(fractionCompleted: fractionComplete)
                
                
            case .ended:
                if (lastFraction < 0.1) {
                    stopAndGoToStartPositionInteractiveTransition()
                } else {
                    continueInteractiveTransition()
                }
                
            default:
                break
            }

        }
    


    //MARK: - Interactions and Animations

    /**
    Starts an interactive Card transition

    - Parameter state: The card state which is either "Expanded" or "Collapsed".
    - Parameter duration: Duration of the animation.
    */
    func startInteractiveTransition (forState state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(with: state, for: duration, withDampingRatio: 0.8)
        }

        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }


    /**
    Updates animators' fraction of the animation that is completed

    - Parameter fractionCompleted: fraction of the animation calculated beforehand.
    */
    func updateInteractiveTransition (fractionCompleted: CGFloat) {
       for animator in runningAnimations {
           animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
       }
        
    }


    /**
    Continues all remaining animations
    */
    func continueInteractiveTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    /**
    Stops animation and goes to start of the animation
    */
    func stopAndGoToStartPositionInteractiveTransition() {
        for animator in runningAnimations {
            animator.stopAnimation(false)
            animator.finishAnimation(at: .start)
        }
        self.runningAnimations.removeAll()
        
        cardVisible = !cardVisible
    }
    
    
    
    /**
    Creates array of animations and starts them

    - Parameter state: The card state which is either ".Expanded" or ".Collapsed".
    - Parameter duration: Duration of the animation.
    */
    func animateTransitionIfNeeded (with state: CardState, for duration: TimeInterval, withDampingRatio dumpingRatio: CGFloat) {

        /* Size animation */
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dumpingRatio) {
            switch state {
            case .Expanded:
                self.cardViewController!.view.frame.origin.y = self.mainViewHeight - self.cardHeight

            case .Collapsed:
                self.cardViewController!.view.frame.origin.y = self.cardStartPointY
            }
        }

        frameAnimator.startAnimation()
        runningAnimations.append(frameAnimator)

        
        /* Blur animation*/
        let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dumpingRatio) {
            switch state {
            case .Expanded:
                self.visualEffectView!.effect = UIBlurEffect(style: .dark)
            case .Collapsed:
                self.visualEffectView!.effect = nil
            }
        }

        blurAnimator.startAnimation()
        runningAnimations.append(blurAnimator)
        
        
        /* Add Button Opacity animation*/
        let buttonOpacityAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dumpingRatio) {
            switch state {
            case .Expanded:
                self.addButton!.alpha = 0
            case .Collapsed:
                self.addButton!.alpha = 1
            }
        }

        buttonOpacityAnimator.startAnimation()
        runningAnimations.append(buttonOpacityAnimator)
        
        
        
        frameAnimator.addCompletion { _ in
            cardVisible = !cardVisible
            self.runningAnimations.removeAll()
        }
    }
}

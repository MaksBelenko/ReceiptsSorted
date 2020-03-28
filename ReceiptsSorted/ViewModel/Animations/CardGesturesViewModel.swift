//
//  CardGesturesViewModel.swift
//  ReceiptsSorted
//
//  Created by Maksim on 24/02/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

var cardVisible = false
var nextState: CardState {
    return cardVisible ? .Collapsed : .Expanded
}
var fractionComplete: CGFloat = 0.0




class CardGesturesViewModel {
    
    var cardHeight: CGFloat!
    var cardStartPointY: CGFloat!
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    var lastFraction: CGFloat = 0
    
//    var addButtonAlpha: Observable<CGFloat> = Observable(1.0)
    
    private var mainView: UIView!
    
    var MainView: UIView {
        get { return mainView }
        set {
            mainView = newValue
            cardStartPointY = mainView.frame.size.height / 2
            cardHeight = mainView.frame.size.height * 19/20
        }
    }
    
    var cardViewController: CardViewController!
    var visualEffectView: UIVisualEffectView!
    var addButton: UIButton!
    
    var ignoreCardAnimation = false
    
    enum MovementDirection {
        case Up, Down
    }

    
    //MARK: - Public methods
    
    func handleCardPan(recogniser: UIPanGestureRecognizer) {
        switch recogniser.state {
            case .began:
//                print("Recogniser velocity: \(recogniser.velocity(in: recogniser.view).y)")
//                print("next state = \(nextState)")
                let direction = getMovementDirection(for: recogniser.velocity(in: recogniser.view).y)
                        
                if ((cardVisible == true && direction == .Up) || (cardVisible == false && direction == .Down) /*|| cardViewController.tblView.contentOffset.y > 0*/) {
                    ignoreCardAnimation = true
                    fractionComplete = 0
                } else {
                    ignoreCardAnimation = false
                }
//                print("Ignore card animation = \(ignoreCardAnimation)")
                if (!ignoreCardAnimation) {
                    startInteractiveTransition(forState: nextState, duration: 0.6)
                }
    
            case .changed:
                if (!ignoreCardAnimation) {
                    let translation = recogniser.translation(in: recogniser.view)
                    fractionComplete = translation.y / (cardStartPointY - mainView.frame.size.height + cardHeight - cardViewController.searchAndSortView.frame.size.height)
                    fractionComplete = cardVisible ? fractionComplete : -fractionComplete

                    lastFraction = fractionComplete
                    updateInteractiveTransition(fractionCompleted: fractionComplete)
                } 
            
            case .ended:
                if (!ignoreCardAnimation) {
                    if (lastFraction < 0.1) {
                        stopAndGoToStartPositionInteractiveTransition()
                    } else {
                        continueInteractiveTransition()
                    }
                }
    
            default:
                break
        }
    }
    
    
     /**
    Creates array of animations and starts them

    - Parameter state: The card state which is either ".Expanded" or ".Collapsed".
    - Parameter duration: Duration of the animation.
    */
    func animateTransitionIfNeeded (with state: CardState, for duration: TimeInterval, withDampingRatio dumpingRatio: CGFloat) {

        print("next state = \(nextState)")
        
        /* Size animation */
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dumpingRatio) {
            switch state {
            case .Expanded:
                self.cardViewController.view.frame.origin.y = self.mainView.frame.height - self.cardHeight

            case .Collapsed:
                self.cardViewController.view.frame.origin.y = self.cardStartPointY
            }
        }

        frameAnimator.startAnimation()
        runningAnimations.append(frameAnimator)

        
        frameAnimator.addCompletion { _ in
            cardVisible = !cardVisible
            self.runningAnimations.removeAll()
        }

        
        /* Blur animation*/
        let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dumpingRatio) {
            switch state {
            case .Expanded:
                self.visualEffectView.effect = UIBlurEffect(style: .dark)
            case .Collapsed:
                self.visualEffectView.effect = nil
            }
        }

        blurAnimator.startAnimation()
        runningAnimations.append(blurAnimator)


        /* Add Button Opacity animation*/
        let buttonOpacityAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dumpingRatio) {
            switch state {
            case .Expanded:
                self.addButton.alpha = 0
            case .Collapsed:
                self.addButton.alpha = 1
            }
        }

        buttonOpacityAnimator.startAnimation()
        runningAnimations.append(buttonOpacityAnimator)
        
        
        switch state {
        case .Expanded:
//            NSLayoutConstraint.deactivate([self.cardViewController.searchAndSortView.topAnchor.constraint(equalTo: NSLayoutAnchor<NSLayoutYAxisAnchor>)])
            searchTopAnchor?.isActive = false
            searchTopAnchor = self.cardViewController.searchAndSortView.topAnchor.constraint(equalTo: self.cardViewController.view.topAnchor, constant: 32)
            searchTopAnchor?.isActive = true
        case .Collapsed:
            searchTopAnchor?.isActive = false
            searchTopAnchor = self.cardViewController.searchAndSortView.topAnchor.constraint(equalTo: self.cardViewController.view.topAnchor, constant: -11)
            searchTopAnchor?.isActive = true
        }
        
        
        /* Top Search and Sort bar hide/unhide */
        let searchViewAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dumpingRatio) {
            self.cardViewController.view.layoutIfNeeded()
        }
        

        searchViewAnimator.startAnimation()
        runningAnimations.append(searchViewAnimator)

    }
    
    
    
    
    
    
    //MARK: - Private methods
    
    /**
    Starts an interactive Card transition

    - Parameter state: The card state which is either "Expanded" or "Collapsed".
    - Parameter duration: Duration of the animation.
    */
    private func startInteractiveTransition (forState state: CardState, duration: TimeInterval) {
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
    private func updateInteractiveTransition (fractionCompleted: CGFloat) {
       for animator in runningAnimations {
           animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
       }

    }


    /**
    Continues all remaining animations
    */
    private func continueInteractiveTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }

    /**
    Stops animation and goes to start of the animation
    */
    private func stopAndGoToStartPositionInteractiveTransition() {
        for animator in runningAnimations {
            animator.stopAnimation(false)
            animator.finishAnimation(at: .current)
        }
        self.runningAnimations.removeAll()
//        cardVisible = !cardVisible
        animateTransitionIfNeeded(with: nextState, for: 0, withDampingRatio: 1)

    }
    
    
    
    
    
    
    private func getMovementDirection(for velocity: CGFloat) -> MovementDirection {
        if (velocity >= 0) {
            return .Down
        } else {
            return .Up
        }
    }
}

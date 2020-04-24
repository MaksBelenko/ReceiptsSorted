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

var searchTopAnchor: NSLayoutConstraint?
var searchBottomAnchor: NSLayoutConstraint?
var noReceiptImageCenterYAnchor: NSLayoutConstraint?

var cardCollapsedProportion = 0.70
var cardExpandedProportion = 0.94





class CardGesturesViewModel: NSObject {
    
    var cardHeight: CGFloat!
    var cardStartPointY: CGFloat!
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    var lastFraction: CGFloat = 0
    
    private var mainView: UIView!
    
    var MainView: UIView {
        get { return mainView }
        set {
            mainView = newValue
            let viewHeight = mainView.frame.size.height
            cardStartPointY = viewHeight - viewHeight*CGFloat(cardCollapsedProportion)
            cardHeight = viewHeight * CGFloat(cardExpandedProportion)
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
    
    @objc func handleCardPan(recogniser: UIPanGestureRecognizer) {
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
                    startInteractiveTransition(forState: nextState, duration: 0.5)
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

//        print("next state = \(nextState)")
        
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
            self.mainView.layoutIfNeeded()
            switch state {
            case .Expanded:
                self.addButton.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi*0.5), 1, 0, 0) //put back 90 deg
                self.addButton.alpha = 0
            case .Collapsed:
                self.addButton.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0) //put to initial state
                self.addButton.alpha = 1
            }
        }

        buttonOpacityAnimator.startAnimation()
        runningAnimations.append(buttonOpacityAnimator)
        
        
        
        /* Top Search and Sort bar hide/unhide */
        NSLayoutConstraint.deactivate([searchTopAnchor!, searchBottomAnchor!, noReceiptImageCenterYAnchor!])
        switch state {
        case .Expanded:
            searchTopAnchor = self.cardViewController.searchAndSortView.topAnchor.constraint(equalTo: self.cardViewController.view.topAnchor, constant: 15)
            searchBottomAnchor = self.cardViewController.searchAndSortView.bottomAnchor.constraint(equalTo: self.cardViewController.SortSegmentedControl.topAnchor, constant: -15)
            noReceiptImageCenterYAnchor = self.cardViewController.noReceiptsImage?.centerYAnchor.constraint(equalTo: self.cardViewController.tblView.centerYAnchor)
        case .Collapsed:
            searchTopAnchor = self.cardViewController.searchAndSortView.topAnchor.constraint(equalTo: self.cardViewController.view.topAnchor, constant: -(self.cardViewController.searchAndSortView.frame.size.height))
            searchBottomAnchor = self.cardViewController.searchAndSortView.bottomAnchor.constraint(equalTo: self.cardViewController.SortSegmentedControl.topAnchor, constant: -25)
            noReceiptImageCenterYAnchor = self.cardViewController.noReceiptsImage?.centerYAnchor.constraint(equalTo: self.cardViewController.tblView.centerYAnchor, constant: -cardStartPointY/2)
        }
        NSLayoutConstraint.activate([searchTopAnchor!, searchBottomAnchor!, noReceiptImageCenterYAnchor!])
        
        
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

//MARK: - Handling Gestures
extension CardGesturesViewModel: UIGestureRecognizerDelegate {

    //Deactivates PanGesture for TableView if the movement is horizontal
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: self.cardViewController.tblView)
            if (abs(translation.x) < abs(translation.y)) {
                return true
            }
        }
        return false
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            if cardViewController.tblView.contentOffset.y > 1 && nextState == .Collapsed {
                return true
            }
        }
        return false
    }
    
    
    // Enable multiple gesture recognition
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer is UIPanGestureRecognizer) ? true : false
    }
}

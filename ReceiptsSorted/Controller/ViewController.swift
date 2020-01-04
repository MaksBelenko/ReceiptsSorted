//
//  ViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 16/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import CoreData

//var cardHeight: CGFloat = 0



class ViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate  {
    
    
    @IBOutlet var imageTake: UIImageView!
    
    var visualEffectView : UIVisualEffectView!  //For blur
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    var cardViewController : CardViewController!
    var cardVisible = false
    var nextState: CardState {
        return cardVisible ? .Collapsed : .Expanded
    }
    var cardHeight: CGFloat = 0
    var cardStartPointY: CGFloat = 0
    var lastFraction: CGFloat = 0
    
    let circularTransition = CircularTransition()
    var cameraViewController: CameraViewController!
    var addButton: UIButton!
    
    var ignoreGesture: Bool = false
    
    //var cameraSession = CameraSession()  //Initialised
    
    
    
    //set Status Bar icons to white
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCard()
        setupAddButton(withSize: self.view.frame.size.width / 4.5)
    }

    
    
    
    //MARK: - Setup Button
    func setupAddButton(withSize buttonSize: CGFloat) {
        
        addButton = UIButton(type: .system)
        
        let buttonPositionX = self.view.frame.size.width - buttonSize - self.view.frame.size.width/20
        let buttonPositionY = self.view.frame.size.height - buttonSize - self.view.frame.size.height/18
        addButton.frame = CGRect(x: buttonPositionX, y: buttonPositionY, width: buttonSize, height: buttonSize)
        addButton.backgroundColor = UIColor(rgb: 0xEDB200)  //orange Flat UI
        
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 70)
        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        addButton.setTitleColor(.white, for: .normal)
        
        addButton.addTarget(self, action: #selector(ViewController.handleAddButton), for: UIControl.Event.touchUpInside)
        self.view.addSubview(addButton)
        
        addButton.layer.applyShadow(color: .black, alpha: 0.25, x: 5, y: 10, blur: 10)
        addButton.layer.cornerRadius = buttonSize/2
    }
    
    
    
    @objc func handleAddButton () {
        
        let cameraVC = CameraViewController(nibName: "CameraViewController", bundle: nil)
        cameraVC.transitioningDelegate = self
        cameraVC.modalPresentationStyle = .custom
        
        cameraVC.controllerFrame = self.view.frame
//        cameraVC.captureSession = cameraSession.captureSession
//        cameraVC.photoOutput = cameraSession.photoOutput
//        cameraVC.cameraPreviewLayer = cameraSession.cameraPreviewLayer
        
        cameraVC.mainView = self
        
        self.present(cameraVC, animated: true, completion: nil)
    }
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        circularTransition.transitionMode = .present
        circularTransition.startingPoint = addButton.center
        circularTransition.circleColor = addButton.backgroundColor!
                
        return circularTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        circularTransition.transitionMode = .dismiss
        circularTransition.startingPoint = addButton.center
        circularTransition.circleColor = addButton.backgroundColor!
        
        return circularTransition
    }
    
    
    
    
    //MARK: - Card Setup
    
    func setupCard() {
        cardStartPointY = self.view.frame.size.height * 1/2
        cardHeight = self.view.frame.size.height * 19/20
        
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        visualEffectView.isUserInteractionEnabled = false
        self.view.addSubview(visualEffectView)
        
        cardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
        cardViewController.cardHeight = cardHeight
        
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: cardStartPointY , width: self.view.bounds.width, height: cardHeight)
        
        cardViewController.view.clipsToBounds = true
        cardViewController.view.roundCorners(corners: [.topLeft, .topRight], radius: 30)
        
        // Create gesture recognisers
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recogniser:)))
        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recogniser:)))
        
        panGestureRecogniser.delegate = self
        
        // Add gestures for Handle Area in the CardViewController.xib
        cardViewController.handleArea.addGestureRecognizer(tapGestureRecogniser)
        //cardViewController.handleArea.addGestureRecognizer(panGestureRecogniser)
        
        cardViewController.tblView.addGestureRecognizer(panGestureRecogniser)
        
    }
    
    
    //MARK: - Handling Gestures

    //Deactivates PanGesture for TableView if the movement is horizontal
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: self.cardViewController.tblView)
            //print("x = \(translation.x)      y = \(translation.y)")
            if (abs(translation.x) < abs(translation.y)) { return true }
        }
        return false
    }
    
    
    // Enable multiple gesture recognition
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return (gestureRecognizer is UIPanGestureRecognizer) ? true : false
    }
    
    
    
    @objc func handleCardTap(recogniser: UITapGestureRecognizer) {
        animateTransitionIfNeeded(with: nextState, for: 0.7, withDampingRatio: 0.8)
    }


    
    @objc func handleCardPan (recogniser: UIPanGestureRecognizer) {
        
        switch recogniser.state{
        case .began:
//            print(cardVisible)
//            print("velocity = \(recogniser.velocity(in: self.view).y)")
            
            let logicExpanded = cardVisible == true && (recogniser.velocity(in: self.view).y < 0 || cardViewController.tblView.contentOffset.y > 0 )
            let logicCollapsed = cardVisible == false && (recogniser.velocity(in: self.view).y > 0)
            
            
            if (logicExpanded || logicCollapsed) {
                ignoreGesture = true
            } else {
                ignoreGesture = false
                startInteractiveTransition(forState: nextState, duration: 0.6)
            }
            

        case .changed:
            if (ignoreGesture == false) {
                let translation = recogniser.translation(in: self.cardViewController.tblView)
                var fractionComplete = translation.y / (cardStartPointY - self.view.frame.size.height + cardHeight)
                fractionComplete = cardVisible ? fractionComplete : -fractionComplete

                
                lastFraction = fractionComplete
                //print("lastFraction = \(lastFraction)")
                if (fractionComplete <= 0) {
                    return
                }
                
                updateInteractiveTransition(fractionCompleted: fractionComplete)
                
                
                // Keep TableView at 0 on Y axis
                //print("fractionComplete = \(fractionComplete)")
                if (fractionComplete > 0 && fractionComplete < 1 ) {
                    cardViewController.tblView.contentOffset.y = 0
                }
            }
            
            if (cardVisible == false && cardViewController.tblView.contentOffset.y >= 0) {
                cardViewController.tblView.contentOffset.y = 0
            }
            
            
        case .ended:
            if (ignoreGesture == false) {
                continueInteractiveTransition()
                
                cardViewController.tblView.isUserInteractionEnabled = false
                
                if (lastFraction > 0 && lastFraction < 1) {
                    cardViewController.tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
                }
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
    Creates array of animations and starts them

    - Parameter state: The card state which is either ".Expanded" or ".Collapsed".
    - Parameter duration: Duration of the animation.
    */
    func animateTransitionIfNeeded (with state: CardState, for duration: TimeInterval, withDampingRatio dumpingRatio: CGFloat) {

        /* Size animation*/
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dumpingRatio) {

            switch state {
            case .Expanded:
                self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight

            case .Collapsed:
                self.cardViewController.view.frame.origin.y = self.cardStartPointY
            }
        }

        frameAnimator.addCompletion { _ in
            self.cardVisible = !self.cardVisible
            self.runningAnimations.removeAll()
            self.cardViewController.tblView.isUserInteractionEnabled = true
        }

        frameAnimator.startAnimation()
        runningAnimations.append(frameAnimator)

        
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
        let buttonOpacityAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
            switch state {
            case .Expanded:
                self.addButton.alpha = 0
            case .Collapsed:
                self.addButton.alpha = 1
            }
        }

        buttonOpacityAnimator.startAnimation()
        runningAnimations.append(buttonOpacityAnimator)
        
    }
    
    
//    func addAnimation(for state: CardState,
//                      duration: TimeInterval,
//                      dampingRatio: CGFloat,
//                      whenExpanded funcExpanded: @escaping () -> (),
//                      whenCollapsed funcCollapsed: @escaping () -> (),
//                      _ completion: @escaping (UIViewAnimatingPosition) -> Void)
//    {
//        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: dampingRatio) {
//            switch state {
//            case .Expanded:
//                funcExpanded()
//            case .Collapsed:
//                funcCollapsed()
//            }
//        }
//
//        animator.addCompletion(completion)
//        animator.startAnimation()
//        runningAnimations.append(animator)
//    }

}







extension ViewController: PaymentDelegate {
    
    func passData(amountPaid: String, place: String, date: String, receiptImage: UIImage) {
        
        
//        cardViewController.payments.insert(CardViewController.Payment(amountPaid, place, date, receiptImage), at: 0)
        
        
        let newPayment = Payments(context: cardViewController.context)
        newPayment.amountPaid = amountPaid
        newPayment.place = place
        newPayment.date = date
        
        cardViewController.payments.insert(newPayment, at: 0)
        
//        cardViewController.tblView.beginUpdates()
//        cardViewController.tblView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .left)
//        cardViewController.tblView.endUpdates()
        
        cardViewController.saveContext()
        cardViewController.tblView.reloadData()
    }
    
    
}

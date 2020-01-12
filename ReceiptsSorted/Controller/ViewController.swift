//
//  ViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 16/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import CoreData

var cardVisible = false
var nextState: CardState {
    return cardVisible ? .Collapsed : .Expanded
}
var fractionComplete: CGFloat = 0.0


class ViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate  {
    
    
    @IBOutlet var imageTake: UIImageView!
    
    var visualEffectView : UIVisualEffectView!  //For blur
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    var cardViewController : CardViewController!
//    var cardVisible = false
//    var nextState: CardState {
//        return cardVisible ? .Collapsed : .Expanded
//    }
    var cardHeight: CGFloat = 0
    var cardStartPointY: CGFloat = 0
    var lastFraction: CGFloat = 0
    
    let circularTransition = CircularTransition()
    var cameraViewController: CameraViewController!
    var addButton: UIButton!
    
    var ignoreGesture: Bool = false
    
    var cameraSession = CameraSession()  //Initialised
    
    
    
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
        
        cameraVC.captureSession = cameraSession.captureSession
        cameraVC.photoOutput = cameraSession.photoOutput
        cameraVC.cameraPreviewLayer = cameraSession.cameraPreviewLayer
        
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
//            print("x = \(translation.x)      y = \(translation.y)")
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
    
    
    
    
    @objc func handleCardTap(recogniser: UITapGestureRecognizer) {
        animateTransitionIfNeeded(with: nextState, for: 0.7, withDampingRatio: 0.8)
    }

    
     @objc func handleCardPan (recogniser: UIPanGestureRecognizer) {
            
            switch recogniser.state{
            case .began:
                startInteractiveTransition(forState: nextState, duration: 0.6)
                
            case .changed:
                let translation = recogniser.translation(in: self.cardViewController.tblView)
                fractionComplete = translation.y / (cardStartPointY - self.view.frame.size.height + cardHeight)
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
            cardVisible = !cardVisible
            self.runningAnimations.removeAll()
            //self.cardViewController.tblView.isUserInteractionEnabled = true
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
        
        let newPayment = Payments(context: cardViewController.database.context)
        newPayment.amountPaid = amountPaid
        newPayment.place = place
        newPayment.date = date
        if let imageData = receiptImage.jpegData(compressionQuality: 1.0) {
             let bytes = imageData.count
            print("size in kB = \(Double(bytes) / 1000.0)")
        }
        if let imageData = receiptImage.jpegData(compressionQuality: 0.1) {
             let bytes = imageData.count
            print("size COMPRESSED in kB = \(Double(bytes) / 1000.0)")
        }
        newPayment.receiptPhoto = receiptImage.jpegData(compressionQuality: 0.1)
        
        cardViewController.payments.insert(newPayment, at: 0)
        
        cardViewController.database.saveContext()
        
//        cardViewController.tblView.reloadData()
        cardViewController.tblView.beginUpdates()
        cardViewController.tblView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .left)
        cardViewController.tblView.endUpdates()
    }
    
    
}

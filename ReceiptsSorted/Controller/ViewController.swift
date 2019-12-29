//
//  ViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 16/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit

var cardHeight: CGFloat = 0



class ViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate  {

    @IBOutlet var imageTake: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var plusButton: UIButton!
    //@IBOutlet weak var emailButton: UIButton!
    //@IBOutlet weak var calendarButton: UIButton!
    //@IBOutlet weak var emailView: UIView!
    
    var imageCmd = ImageCommands()
    
    var cardViewController : CardViewController!
    var visualEffectView : UIVisualEffectView!  //For blur
    
    //var cardHeight: CGFloat = 0
    
    var cardVisible = false
    var nextState: CardState {
        return cardVisible ? .Collapsed : .Expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    var cardStartPointY: CGFloat = 0
    
    var lastFraction: CGFloat = 0
    
    
    //set Status Bar icons to white
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imageCmd.mainView = self
        
        
        
        setupCard()
        setupAddButton(withSize: 90)

    }

    
    
    //MARK: - Setup Button
    func setupAddButton(withSize buttonSize: CGFloat) {
        plusButton.layer.cornerRadius = plusButton.frame.height / 2
        
        
        let addButton = UIButton(type: .system)
        
        let buttonPositionX = self.view.frame.size.width - buttonSize - self.view.frame.size.width/20
        let buttonPositionY = self.view.frame.size.height - buttonSize - self.view.frame.size.height/18
        addButton.frame = CGRect(x: buttonPositionX, y: buttonPositionY, width: buttonSize, height: buttonSize)
        addButton.backgroundColor = UIColor(rgb: 0xEDB200)
        
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 80)
        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        addButton.setTitleColor(.white, for: .normal)
        
        addButton.addTarget(self, action: #selector(ViewController.handleAddButton), for: UIControl.Event.touchUpInside)
        self.view.addSubview(addButton)
        
        addButton.layer.applyShadow(color: .black, alpha: 0.2, x: 5, y: 10, blur: 10)
        addButton.layer.cornerRadius = buttonSize/2
    }
    
    
    @objc func handleAddButton () {
        print("Hi")
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
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: cardStartPointY , width: self.view.bounds.width, height: cardHeight)
        
        cardViewController.view.clipsToBounds = true
        cardViewController.view.layer.cornerRadius = 30
        
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
            if abs(translation.x) < abs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    
    
    

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {

//        print("gesture = \(gestureRecognizer)")
//        print("otherGesture = \(otherGestureRecognizer)")
        
    
        if (gestureRecognizer is UIPanGestureRecognizer || otherGestureRecognizer is UIPanGestureRecognizer) {
            
//            return false
//            print(cardViewController.tblView.contentOffset.y)
//            print("cardVisible = \(cardVisible)")
//            if (cardVisible == false) {
//                return false
//            }
//
            if (cardViewController.tblView.contentOffset.y <= 5) {
                return false
            }
            else {
                //print("true")
                return true
            }
        }

        
        //print("OUTSIDE false")
       return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    @objc func handleCardTap(recogniser: UITapGestureRecognizer) {
        animateTransitionIfNeeded(with: nextState, for: 0.7, withDampingRatio: 0.8)
    }


    @objc func handleCardPan (recogniser: UIPanGestureRecognizer) {
        
        switch recogniser.state{
        case .began:
            startInteractiveTransition(forState: nextState, duration: 0.7)

        case .changed:
            let translation = recogniser.translation(in: self.cardViewController.handleArea)
            var fractionComplete = translation.y / (cardStartPointY - self.view.frame.size.height + cardHeight)
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete

            if (fractionComplete > 0) {
                updateInteractiveTransition(fractionCompleted: fractionComplete)
            }
            // Keep TableView at 0 on Y axis
            //print("fractionComplete = \(fractionComplete)")
            if (fractionComplete > 0 && fractionComplete < 1 ) {
                cardViewController.tblView.contentOffset.y = 0
            }
            
            lastFraction = fractionComplete
//            print("lastFraction = \(lastFraction)")
            
        case .ended:
            
            continueInteractiveTransition()

            cardViewController.tblView.isUserInteractionEnabled = false
            
            if (lastFraction < 1) {
                cardViewController.tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
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
    Stops all animations
    */
    func stopInteractiveTransition() {
//        for animator in runningAnimations {
//            animator.stopAnimation(true)
//        cardVisible = !self.cardVisible
//        runningAnimations.removeAll()
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
                self.cardViewController.view.frame.origin.y = self.view.frame.height - cardHeight

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
    }

    
    
    
    
    
    
    
    

    
    @IBAction func addNewReceipt(_ sender: UIButton) {
   
        imageCmd.handleAddButton()
    }
   
    
    
    @IBAction func saveImageToGallery(_ sender: UIButton) {
        
        //imageCmd.saveImageToGallery()
        
//        guard let selectedImage = imageTake.image else {
//                print("Image not found!")
//                showAlertWith(title: "No image selected!", message: "")
//                return
//            }
//
//            UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    

//    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        if let error = error {
//            showAlertWith(title: "Save error", message: error.localizedDescription)
//        } else {
//            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
//        }
//    }

    
}






//MARK: - EXTENSION for ImagerPicker
 extension ViewController: UIImagePickerControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        imageTake.image = selectedImage
    }
}



extension CALayer {
  func applyShadow(color: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4) {
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0

  }
}






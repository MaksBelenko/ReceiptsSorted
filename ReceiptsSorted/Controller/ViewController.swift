//
//  ViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 16/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit

var cardHeight: CGFloat = 0



class ViewController: UIViewController, UINavigationControllerDelegate  {

    @IBOutlet var imageTake: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var emailView: UIView!
    
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
    
    //set Status Bar icons to white
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCmd.mainView = self
        
        setupButtons()
        
        
        cardStartPointY = self.view.frame.size.height * 2/3
        cardHeight = self.view.frame.size.height * 9/10
        
        setupCard()
        cardViewController.view.layer.cornerRadius = 30
    }

    
    func setupButtons() {
        plusButton.layer.cornerRadius = plusButton.frame.height / 2
        emailView.layer.cornerRadius = emailView.frame.height / 2
        //emailButton.layer.cornerRadius = emailButton.frame.height / 2
        calendarButton.layer.cornerRadius = calendarButton.frame.height / 2
        
        //emailButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20)
        emailButton.imageView?.contentScaleFactor = 2.0
    }
    
    
    //MARK: - Card Setup
    
    func setupCard() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        visualEffectView.isUserInteractionEnabled = false
        self.view.addSubview(visualEffectView)
        
        
        cardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: cardStartPointY , width: self.view.bounds.width, height: cardHeight)
        
        cardViewController.view.clipsToBounds = true
        
        // Create gesture recognisers
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recogniser:)))
        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recogniser:)))
        
        // Add gestures for Handle Area in the CardViewController.xib
        cardViewController.handleArea.addGestureRecognizer(tapGestureRecogniser)
        cardViewController.handleArea.addGestureRecognizer(panGestureRecogniser)
        
        
        
//        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
//        swipeUp.direction = .up
//        cardViewController.tblView.addGestureRecognizer(swipeUp)
//
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
//        swipeDown.direction = .down
//        cardViewController.tblView.addGestureRecognizer(swipeDown)
        
    }
    
    
    //MARK: - Handling Gestures

    
    
//    @objc func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
//        if gesture.direction == .up {
//             print("Swipe Up")
//        }
//
//        if gesture.direction == .down {
//             print("Swipe Down")
//        }
//    }
    
    
    
    @objc func handleCardTap(recogniser: UITapGestureRecognizer) {
        animateTransitionIfNeeded(with: nextState, for: 1)
        
        // Enable/Disable scroll depending on the cardVisible state
        cardViewController.tblView.isScrollEnabled = (cardVisible == false) ? true : false
        
    }


    @objc func handleCardPan (recogniser: UIPanGestureRecognizer) {

//        let velocityX = recogniser.velocity(in: self.view).x
//        let velocityY = recogniser.velocity(in: self.view).y
//
//
//
//        print("x = \(abs(velocityX))     y = \(abs(velocityY))")
//        if (abs(velocityY) > abs(velocityX)) {
//
            switch recogniser.state{
            case .began:
                startInteractiveTransition(forState: nextState, duration: 1)

            case .changed:
                let translation = recogniser.translation(in: self.cardViewController.handleArea)
                var fractionComplete = translation.y / (cardStartPointY - self.view.frame.size.height + cardHeight)
                fractionComplete = cardVisible ? fractionComplete : -fractionComplete
                
                updateInteractiveTransition(fractionCompleted: fractionComplete)

            case .ended:
                continueInteractiveTransition()
                //cardViewController.tableView.isUserInteractionEnabled = true

            default:
                break
            }
//        }

    }
    


    //MARK: - Interactions and Animations

    /**
    Starts an interactive Card transition

    - Parameter state: The card state which is either "Expanded" or "Collapsed".
    - Parameter duration: Duration of the animation.
    */
    func startInteractiveTransition (forState state: CardState, duration: TimeInterval) {

       if runningAnimations.isEmpty {
           animateTransitionIfNeeded(with: state, for: duration)
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

        print("animator.fractionComplete = \(runningAnimations[0].fractionComplete)")
        
        // Enable/Disable scroll depending on the cardVisible state
        if (runningAnimations[0].fractionComplete == 1) {
            cardViewController.tblView.isScrollEnabled = (cardVisible == false) ? true : false
        }
    }


    /**
    Continues all the remaining animations
    */
    func continueInteractiveTransition() {
       for animator in runningAnimations {
           animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
       }
        
        // Enable/Disable scroll depending on the cardVisible state
        cardViewController.tblView.isScrollEnabled = (cardVisible == false) ? true : false
    }

    
    
    /**
    Creates array of animations and starts them

    - Parameter state: The card state which is either "Expanded" or "Collapsed".
    - Parameter duration: Duration of the animation.
    */
    func animateTransitionIfNeeded (with state: CardState, for duration: TimeInterval) {

        /* Size animation*/
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {

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
        }

        frameAnimator.startAnimation()
        runningAnimations.append(frameAnimator)


        /* Blur animation*/
        let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
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



//
//  ViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 16/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate  {
    
    //MARK: - Fields
    @IBOutlet weak var amountSum: UILabel!
    
    var visualEffectView : UIVisualEffectView!  //For blur
    var cardViewController : CardViewController!
    var cardHeight: CGFloat = 0
    var cardStartPointY: CGFloat = 0
    
    var addButton: UIButton!
    let addButtonAnimations = AddButtonAnimations()
    var cardGesturesViewModel = CardGesturesViewModel()
    let circularTransition = CircularTransition()
    let emailViewModel = EmailViewModel()
    
    var amountAnimation: AmountAnimation!
    
    let cameraVC = CameraViewController(nibName: "CameraViewController", bundle: nil)
    
    
    
    
    //MARK: - Status Bar
    
    //set Status Bar icons to white
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialiseCircle()
        
        setupCard()
        cardViewController.amountAnimation = amountAnimation
        
        setupAddButton(withSize: self.view.frame.size.width / 4.5)
        
        
        cardGesturesViewModel.MainView = self.view
        cardGesturesViewModel.cardViewController = cardViewController
        cardGesturesViewModel.visualEffectView = visualEffectView
        cardGesturesViewModel.addButton = addButton
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let totalAmount = cardViewController.database.getTotalAmount(of: .Pending)
        amountAnimation.animateCircle(to: totalAmount)
    }
    
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    

    
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
        addButton.addTarget(self, action: #selector(ViewController.addButtonPressed), for: UIControl.Event.touchUpInside)
        addButtonAnimations.startAnimatingPressActions(for: addButton)
        
        self.view.addSubview(addButton)
        
        addButton.layer.applyShadow(color: .black, alpha: 0.25, x: 5, y: 10, blur: 10)
        addButton.layer.cornerRadius = buttonSize/2
    }
    
    
    
    @objc func addButtonPressed () {
        let cameraVC = CameraViewController(nibName: "CameraViewController", bundle: nil)
        cameraVC.transitioningDelegate = self
        cameraVC.modalPresentationStyle = .custom
        cameraVC.controllerFrame = self.view.frame

        cameraVC.mainView = cardViewController
        
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
        cardStartPointY = self.view.frame.size.height / 2
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
        
        // Add gestures for Handle Area in the CardViewController.xib
        cardViewController.handleArea.addGestureRecognizer(tapGestureRecogniser)
        cardViewController.handleArea.addGestureRecognizer(setPanGestureRecognizer())
        
        // Add gestures for TableView in the CardViewController.xib
        cardViewController.tblView.addGestureRecognizer(setPanGestureRecognizer())
    }
    
    
    // For multiple views to have the same PanGesture
    func setPanGestureRecognizer() -> UIPanGestureRecognizer {
        let panGestureRecogniser = UIPanGestureRecognizer (target: self, action: #selector(ViewController.handleCardPan(recogniser:)))
        panGestureRecogniser.delegate = self

        panGestureRecogniser.minimumNumberOfTouches = 1
        panGestureRecogniser.maximumNumberOfTouches = 4
        return panGestureRecogniser
    }
    
    
    
    //MARK: - Handling Gestures

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
    
    
    
    @objc func handleCardTap(recogniser: UITapGestureRecognizer) {
        cardGesturesViewModel.animateTransitionIfNeeded(with: nextState, for: 0.7, withDampingRatio: 0.8)
    }


     @objc func handleCardPan (recogniser: UIPanGestureRecognizer) {
        cardGesturesViewModel.handleCardPan(recogniser: recogniser)
    }


    
    
    //MARK: - Initialisation of Top graphics
    func initialiseCircle() {
        
        let mainGraphics = MainGraphicsViewModel(frameWidth: view.frame.size.width, frameHeight: view.frame.size.height)
        
        let whiteCircle = mainGraphics.createCircleLine(from: CGFloat.pi*3/4, to: CGFloat.pi*1/4, ofColour: UIColor.white.cgColor)
        let redCircle = mainGraphics.createCircleLine(from: CGFloat.pi*3/4, to: CGFloat.pi*1/4, ofColour: UIColor(rgb: 0xC24D35).cgColor)
        
        let lightGreenBar = mainGraphics.createHorizontalBar(percentage: 1, colour: UIColor(rgb: 0xC0CEB7))
        let lightRedBar = mainGraphics.createHorizontalBar(percentage: 0.7, colour: UIColor(rgb: 0xCA8D8B))
        
        view.layer.addSublayer(whiteCircle)
        view.layer.addSublayer(redCircle)
        for layer in mainGraphics.createEmptySpaces(amount: 55) {
            view.layer.addSublayer(layer)
        }
        view.layer.addSublayer(lightGreenBar)
        view.layer.addSublayer(lightRedBar)
        
        
        
        amountAnimation = AmountAnimation(animationCircle: redCircle)
        
        amountAnimation.overallAmount.bind { [weak self] in
            self?.amountSum.text = "-£\($0.ToString(decimals: 2))" 
        }
    }
    
         
    
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        
        let emailViewController = emailViewModel.sendMail()
        self.present(emailViewController, animated: true, completion: nil)
    }
    
}





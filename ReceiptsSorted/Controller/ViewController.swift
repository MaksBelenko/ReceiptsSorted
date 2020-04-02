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
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailButton: UIButton!
    
    
    var emailContainerViewHeight = NSLayoutConstraint()
    var emailContainerViewWidth = NSLayoutConstraint()
    
    
    var visualEffectView : UIVisualEffectView!  //For blur
    var cardViewController : CardViewController!
    var cardHeight: CGFloat = 0
    var cardStartPointY: CGFloat = 0
    
    var addButton: UIButton!
    let buttonAnimations = AddButtonAnimations()
    var cardGesturesViewModel = CardGesturesViewModel()
    let circularTransition = CircularTransition()
    let emailViewModel = EmailViewModel()
    let emailButtonAnimations = EmailButtonAnimations()
    
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
        setupEmailView()
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
        addButton.backgroundColor = UIColor.flatOrange //orange Flat UI
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 70)
        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        addButton.setTitleColor(.white, for: .normal)
        addButton.addTarget(self, action: #selector(ViewController.addButtonPressed), for: UIControl.Event.touchUpInside)
        buttonAnimations.startAnimatingPressActions(for: addButton)
        
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
        
        view.layer.insertSublayer(whiteCircle, at: 0) //addSublayer(whiteCircle)
        view.layer.insertSublayer(redCircle, at: 1) //addSublayer(redCircle)
        for layer in mainGraphics.createEmptySpaces(amount: 55) {
            view.layer.insertSublayer(layer, at: 2)
        }
        view.layer.addSublayer(lightGreenBar)
        view.layer.addSublayer(lightRedBar)
        
        
        
        amountAnimation = AmountAnimation(animationCircle: redCircle)
        
        amountAnimation.overallAmount.bind { [weak self] in
            self?.amountSum.text = "-£\($0.ToString(decimals: 2))" 
        }
    }
    
         
    
    
    func setupEmailView() {
        emailContainerView.layer.cornerRadius = 20
        
        emailContainerView.translatesAutoresizingMaskIntoConstraints = false
        emailContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        emailContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        emailContainerViewHeight = emailContainerView.heightAnchor.constraint(equalTo: emailButton.heightAnchor, constant: 20)
        emailContainerViewWidth  = emailContainerView.widthAnchor.constraint(equalTo: emailButton.widthAnchor, constant: 20)
        NSLayoutConstraint.activate([emailContainerViewHeight, emailContainerViewWidth])
        
    }
    
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
//        emailButtonAnimations.animate(button: emailButton)
        
//        let emailViewController = emailViewModel.sendMail()
//        self.present(emailViewController, animated: true, completion: nil)
        
        NSLayoutConstraint.deactivate([emailContainerViewHeight, emailContainerViewWidth])
        emailContainerViewHeight.constant = 125
        emailContainerViewWidth.constant  = 140
        NSLayoutConstraint.activate([emailContainerViewHeight, emailContainerViewWidth])
        
        self.emailButton.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        
        let circleView = UIView(frame: CGRect(x: 8, y: 8, width: emailButton.frame.size.width, height: emailButton.frame.size.height))
        circleView.backgroundColor = UIColor.wetAsphalt
        circleView.layer.cornerRadius = circleView.frame.size.height / 2
        emailContainerView.insertSubview(circleView, at: 0)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.emailContainerView.backgroundColor = UIColor(rgb: 0x213345).withAlphaComponent(0.8)
            self.emailButton.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
        }
        
        let buttonPending = createEmailSubviewButton(withTitle: "All Pending", yOffset: 55, width: 160)
        let buttonSelect = createEmailSubviewButton(withTitle: "Select", yOffset: 110, width: 100)
        emailContainerView.addSubview(buttonPending)
        emailContainerView.addSubview(buttonSelect)
        
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveLinear, animations: {
            buttonPending.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveLinear, animations: {
            buttonSelect.alpha = 1
        }, completion: nil)
    }
    
    
    
    func createEmailSubviewButton(withTitle buttonTitle: String, yOffset: Int, width: Int) -> UIButton {
        let button = UIButton(type: .system)

        button.frame = CGRect(x: 8, y: yOffset, width: width, height: 40)
        button.backgroundColor = UIColor.flatOrange //orange Flat UI
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = button.frame.size.height / 2

        button.alpha = 0 // Make it invisible first
         
        return button
    }
    
}





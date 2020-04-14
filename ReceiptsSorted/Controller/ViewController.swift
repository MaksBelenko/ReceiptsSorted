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
    @IBOutlet weak var emailButton: UIButton!
    
    var amountSum: UILabel!
    
    var emailContainerViewHeight = NSLayoutConstraint()
    var emailContainerViewWidth = NSLayoutConstraint()
    
    var visualEffectView : UIVisualEffectView!  //For blur
    var cardViewController : CardViewController!
    var cardHeight: CGFloat = 0
    var cardStartPointY: CGFloat = 0
    
    var addButton: UIButton!
    var buttonView: UIView!
    let buttonAnimations = AddButtonAnimations()
    var cardGesturesViewModel = CardGesturesViewModel()
    let circularTransition = CircularTransition()
    
    var amountAnimation: AmountAnimation!
    
    let cameraVC = CameraViewController(nibName: "CameraViewController", bundle: nil)
    
    
    
    
    
    //MARK: - Status Bar
    
    //set Status Bar icons to white
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        initialiseCircle()
        
        
        setupCard()
        setupCardHandle()
        setupTopViewWithGraphics()
        cardViewController.amountAnimation = amountAnimation
        
        setupAddButton(withSize: 55)
        
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
//        amountAnimation.animateCircle(to: totalAmount)
    }
    
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    

    
    //MARK: - Setup Button
    func setupAddButton(withSize buttonSize: CGFloat) {
        
        /* Adding UIView that will contain button (needed for  3D Transform*/
        buttonView = UIView(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        self.view.addSubview(buttonView)
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        buttonView.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        buttonView.centerYAnchor.constraint(equalTo: cardViewController.view.topAnchor, constant: -8).isActive = true
        buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        
        /* Creating Add Button */
        addButton = UIButton(type: .system)
        addButton.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        addButton.backgroundColor = UIColor.flatOrange //orange Flat UI
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 45)
        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        addButton.setTitleColor(.white, for: .normal)
        addButton.addTarget(self, action: #selector(ViewController.addButtonPressed), for: UIControl.Event.touchUpInside)
        buttonAnimations.startAnimatingPressActions(for: addButton)
        
        
        /* Adding Transform Layer to enable 3D animation*/
        var perspective = CATransform3DIdentity
        perspective.m34 = -1 / 1000
        let transformLayer = CATransformLayer()
        transformLayer.transform = perspective

        transformLayer.addSublayer(addButton.layer)
        buttonView.layer.addSublayer(transformLayer)

        addButton.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0) //CGFloat(M_PI*0.5)
        
        
        /* Add Button to button view and adjust corner radius*/
        buttonView.addSubview(addButton)
        
        addButton.layer.applyShadow(color: .flatOrange, alpha: 0.5, x: 1, y: 2, blur: 4)
        addButton.layer.cornerRadius = 18
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
        circularTransition.startingPoint = buttonView.center
        circularTransition.circleColor = addButton.backgroundColor!
        
        return circularTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        circularTransition.transitionMode = .dismiss
        circularTransition.startingPoint = buttonView.center
        circularTransition.circleColor = addButton.backgroundColor!
        
        return circularTransition
    }
    
    
    
    
    //MARK: - Card Setup
    
    func setupCard() {
        let viewHeight = self.view.frame.size.height
        cardStartPointY = viewHeight - viewHeight * CGFloat(cardCollapsedProportion)
        cardHeight = viewHeight * CGFloat(cardExpandedProportion)
        
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
        cardViewController.view.roundCorners(corners: [.topLeft, .topRight], radius: 25)
        
        // Create gesture recognisers
//        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recogniser:)))
        
        // Add gestures for Handle Area in the CardViewController.xib
//        cardViewController.handleArea.addGestureRecognizer(tapGestureRecogniser)
//        cardViewController.handleArea.addGestureRecognizer(setPanGestureRecognizer())
        
        // Add gestures for TableView in the CardViewController.xib
        cardViewController.tblView.addGestureRecognizer(setPanGestureRecognizer())
    }
    
    
    /// For multiple views to have the same PanGesture
    func setPanGestureRecognizer() -> UIPanGestureRecognizer {
        let panGestureRecogniser = UIPanGestureRecognizer (target: self, action: #selector(ViewController.handleCardPan(recogniser:)))
        panGestureRecogniser.delegate = self

        panGestureRecogniser.minimumNumberOfTouches = 1
        panGestureRecogniser.maximumNumberOfTouches = 4
        return panGestureRecogniser
    }
    
    
    
    
    func setupCardHandle() {
        let handleView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 3))
        handleView.backgroundColor = .white
        
        self.view.addSubview(handleView)
        
        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.centerXAnchor.constraint(equalTo: cardViewController.view.centerXAnchor).isActive = true
        handleView.bottomAnchor.constraint(equalTo: cardViewController.view.topAnchor, constant: -10).isActive = true
        handleView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        handleView.heightAnchor.constraint(equalToConstant: 3).isActive = true
      
        handleView.layer.cornerRadius = handleView.frame.height
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
        let redCircle = mainGraphics.createCircleLine(from: CGFloat.pi*3/4, to: CGFloat.pi, ofColour: UIColor(rgb: 0xC24D35).cgColor)
        
        let lightGreenBar = mainGraphics.createHorizontalBar(percentage: 1, colour: UIColor(rgb: 0xC0CEB7))
        let lightRedBar = mainGraphics.createHorizontalBar(percentage: 0.7, colour: UIColor(rgb: 0xCA8D8B))
        
        view.layer.insertSublayer(whiteCircle, at: 0)
        view.layer.insertSublayer(redCircle, at: 1)
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
    
         
    
    private func setupTopViewWithGraphics() {
        let topView = UIView()
        topView.backgroundColor = .wetAsphalt
        
        view.insertSubview(topView, at: 0)
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: cardStartPointY).isActive = true
        
        
        let mainGraphics = MainGraphicsViewModel(frameWidth: view.frame.size.width, frameHeight: cardStartPointY)
        let contourCircle = mainGraphics.createCircleLine(from: 0, to: CGFloat.pi*2, ofColour: UIColor.contourFlatColour.cgColor)
        let indicatorCircle = mainGraphics.createCircleLine(from: -CGFloat.pi/2, to: 0, ofColour: UIColor.flatOrange.cgColor)
        
        topView.layer.addSublayer(contourCircle)
        topView.layer.addSublayer(indicatorCircle)
        
        contourCircle.applyShadow(color: .black, alpha: 0.16, x: 2, y: 2, blur: 3)
        indicatorCircle.applyShadow(color: .flatOrange, alpha: 0.7, x: 0, y: 1, blur: 6)
        
        
        
        let currencyLabel = UILabel()
        currencyLabel.text = "£"
        currencyLabel.textColor = .flatOrange
        currencyLabel.font = UIFont(name: "Arial", size: 46)
        currencyLabel.textAlignment = .center
        currencyLabel.frame.size.height = 50
        currencyLabel.frame.size.width = 50
        currencyLabel.center = CGPoint(x: view.frame.size.width/5, y: cardStartPointY * 0.43)
        
        topView.addSubview(currencyLabel)
        
        currencyLabel.layer.applyShadow(color: .black, alpha: 0.16, x: 2, y: 2, blur: 4)
        
        
        
        
        amountSum = UILabel()
        amountSum.textColor = UIColor(rgb: 0xC6CACE)
        amountSum.font = UIFont(name: "Arial", size: 25)
        amountSum.textAlignment = .right
        
        topView.addSubview(amountSum)
        
        amountSum.translatesAutoresizingMaskIntoConstraints = false
        amountSum.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -25).isActive = true
        amountSum.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive = true
        amountSum.heightAnchor.constraint(equalToConstant: 28).isActive = true
        amountSum.centerYAnchor.constraint(equalTo: currencyLabel.centerYAnchor).isActive = true
        
        
        
        amountAnimation = AmountAnimation(animationCircle: indicatorCircle)
        
        amountAnimation.overallAmount.bind {
            self.amountSum.text = "£\($0.ToString(decimals: 2))"
        }
    }
    
    
    
    
    
    
    
    //MARK: - Email button
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        let pdfPreviewVC = PDFPreviewViewController(nibName: "PDFPreviewViewController", bundle: nil)
        pdfPreviewVC.passedPayments = cardViewController.database.fetchSortedData(by: .NewestDateAdded, and: .Pending)
        self.present(pdfPreviewVC, animated: true)

    }
    
}





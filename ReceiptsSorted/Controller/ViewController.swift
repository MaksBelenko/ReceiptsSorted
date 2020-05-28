//
//  ViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 16/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate  {
    
    //MARK: - Fields
    @IBOutlet weak var emailButton: UIButton!
    
    var visualEffectView : UIVisualEffectView!  //For blur
    var cardViewController : CardViewController!
    var cardHeight: CGFloat = 0
    var cardStartPointY: CGFloat = 0
    
    var buttonView: AddButtonView!
    var cardGesturesViewModel = CardGesturesViewModel()
    let circularTransition = CircularTransition()
    var topGraphicsView: TopGraphicsView!
    
    var onStartup = true
    
    var selectButton: PaymentSelectionButtonView?
    var cancelButton: PaymentSelectionButtonView?
    
    
    //MARK: - Status Bar
    
    //set Status Bar icons to white
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .background).async {
            FileManager.default.cleanTmpDirectory()
        }
        
        setupCard()
        setupCardHandle()
        setupTopViewWithGraphics()
        cardViewController.amountAnimation = topGraphicsView.amountAnimation
        cardViewController.cardGesturesViewModel = cardGesturesViewModel
        
        setupAddButton(withSize: 55)
        
        cardGesturesViewModel.MainView = self.view
        cardGesturesViewModel.cardViewController = cardViewController
        cardGesturesViewModel.visualEffectView = visualEffectView
        cardGesturesViewModel.addButton = buttonView.addButton
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.delegate = self // for custom animation
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if onStartup {
            onStartup = false
            let totalAmount = cardViewController.database.getTotalAmount(of: .Pending)
            topGraphicsView.amountAnimation.animateCircle(to: totalAmount)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.delegate = nil // stop using custom transition
    }
    

    
    //MARK: - Setup Button
    func setupAddButton(withSize buttonSize: CGFloat) {
        buttonView = AddButtonView()
        buttonView.addButton.addTarget(self, action: #selector(ViewController.addButtonPressed), for: UIControl.Event.touchUpInside)
        buttonView.addButton.addTarget(self, action: #selector(ViewController.addButtonTouchDown), for: UIControl.Event.touchDown)
        
        self.view.addSubview(buttonView)
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        buttonView.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        buttonView.centerYAnchor.constraint(equalTo: cardViewController.view.topAnchor, constant: -8).isActive = true
        buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
    }
    
    

    @objc func addButtonPressed () {
        Navigation.shared.showCameraVC(for: self)
    }
    
    
    @objc func addButtonTouchDown() {
        Vibration.light.vibrate()
    }
    
    
    
    //MARK: - Transition animation
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        // Perform custom animation only if CameraViewController
        guard let cameraVC = toVC as? CameraViewController else { return nil }
        
        circularTransition.transitionMode = (operation == .push) ? .present : .pop
        circularTransition.startingPoint = buttonView.center
        cameraVC.addButtonCenter = buttonView.center
        
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
        cardViewController.cardStartPointY = cardStartPointY
        
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: cardStartPointY , width: self.view.bounds.width, height: cardHeight)
        
        cardViewController.view.clipsToBounds = true
        cardViewController.view.roundCorners(corners: [.topLeft, .topRight], radius: 25)
        
        // Add gestures for TableView in the CardViewController.xib
        cardViewController.tblView.addGestureRecognizer(setPanGestureRecognizer())
    }
    
    
    /// For multiple views to have the same PanGesture
    func setPanGestureRecognizer() -> UIPanGestureRecognizer {
        let panGestureRecogniser = UIPanGestureRecognizer (target: cardGesturesViewModel, action: #selector(CardGesturesViewModel.handleCardPan(recogniser:)))
        panGestureRecogniser.delegate = cardGesturesViewModel

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
    
    
    
    //MARK: - Initialisation of Top graphics
    
    private func setupTopViewWithGraphics() {
        topGraphicsView = TopGraphicsView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: cardStartPointY))//UIView()
        
        view.insertSubview(topGraphicsView, at: 0)
        
        topGraphicsView.translatesAutoresizingMaskIntoConstraints = false
        topGraphicsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topGraphicsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topGraphicsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topGraphicsView.heightAnchor.constraint(equalToConstant: cardStartPointY).isActive = true
    }
    
    
    
    //MARK: - Email button
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        cardViewController.selectingPaymentsClicked()
    }
}


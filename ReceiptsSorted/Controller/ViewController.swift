//
//  ViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 16/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController  {
    
    //MARK: - Fields
    @IBOutlet weak var emailButton: UIButton!
    
    private var visualEffectView : UIVisualEffectView!  //For blur
    private var cardHeight: CGFloat = 0
    private var cardStartPointY: CGFloat = 0
    
    private var buttonView: AddButtonView!
    private var cardViewController : CardViewController!
    private var cardGesturesViewModel = CardGesturesViewModel()
    private var topGraphicsView: TopGraphicsView!
    private let userChecker = UserChecker()
    private var navControllerTransitions: NavControllerTransitions!
    
    private var onStartup = true
    
    private let pushNotifications = PushNotificationManager()
    
    
    //MARK: - Status Bar
    
    //set Status Bar icons to white
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        DispatchQueue.global(qos: .background).async {
            FileManager.default.cleanTmpDirectory()
        }
        
        if SettingsUserDefaults.shared.getCurrency() == nil {
            SettingsUserDefaults.shared.setDefaultCurrency(to: "£")
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
        
        DispatchQueue.main.async { [unowned self] in
            self.presentOnboardingIfNeeded(animated: false)
            
            self.view.layoutIfNeeded()
            self.navControllerTransitions = NavControllerTransitions(animationCentre: self.buttonView.center)
            self.navigationController?.delegate = self.navControllerTransitions // for custom animation
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if onStartup {
            onStartup = false
            cardViewController.cardViewModel.database.getTotalAmountAsync(of: .Pending) { totalAmount in
                self.topGraphicsView.amountAnimation.animateCircle(to: totalAmount)
            }
            
            topGraphicsView.dateAnimation.animateToCurrentDate()
            
            pushNotifications.requestAuthorization()
            pushNotifications.getPendingNotificationRequests { [weak self] requests in
                if requests.count == 0 {
                    self?.pushNotifications.schedule(for: SettingsUserDefaults.shared.getIndicatorPeriod())
                }
            }
        }
        
        pushNotifications.removeIconBadge()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    

    // MARK: - Onboarding
    
    private func presentOnboardingIfNeeded(animated: Bool) {        
        if userChecker.isOldUser() { return }
        
        let onboardingVC = OnboardingViewController()
        var onboardTexts = OnboardingText() // texts
        
        var segmentedViewFrame = cardViewController.SortSegmentedControl.frame
        segmentedViewFrame.origin.y += cardStartPointY
        
        let indicatorsYOffset = emailButton.frame.origin.y + emailButton.frame.height
        let indicatorsHeight = buttonView.frame.origin.y - indicatorsYOffset
        let indicatorsFrame = CGRect(origin: CGPoint(x: 0, y: indicatorsYOffset), size: CGSize(width: view.frame.width, height: indicatorsHeight))
        
        onboardingVC.add(info: OnboardingInfo(showRect: segmentedViewFrame, text: onboardTexts.segmentedControlText))
        onboardingVC.add(info: OnboardingInfo(showRect: buttonView.frame,   text: onboardTexts.addReceiptsText))
        onboardingVC.add(info: OnboardingInfo(showRect: emailButton.frame,  text: onboardTexts.sendReceiptsText))
        onboardingVC.add(info: OnboardingInfo(showRect: indicatorsFrame,    text: onboardTexts.indicatorsText))
        
        onboardingVC.modalPresentationStyle = .overFullScreen
        present(onboardingVC, animated: animated)
    }
    
    
    //MARK: - Setup Button
    private func setupAddButton(withSize buttonSize: CGFloat) {
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
    
    
    @objc private func addButtonPressed () {
        Navigation.shared.showCameraVC(for: self)
    }
    
    @objc private func addButtonTouchDown() {
        Vibration.light.vibrate()
    }
 
    
    //MARK: - Card Setup
    
    private func setupCard() {
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
    private func setPanGestureRecognizer() -> UIPanGestureRecognizer {
        let panGestureRecogniser = UIPanGestureRecognizer (target: cardGesturesViewModel, action: #selector(CardGesturesViewModel.handleCardPan(recogniser:)))
        panGestureRecogniser.delegate = cardGesturesViewModel

        panGestureRecogniser.minimumNumberOfTouches = 1
        panGestureRecogniser.maximumNumberOfTouches = 4
        return panGestureRecogniser
    }
    
    
    private func setupCardHandle() {
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
    
    
    //MARK: - Initialisation of Top Indicators
    
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
        fractionComplete = 0
        cardViewController.selectingPayments(mode: .Enable)
    }
}

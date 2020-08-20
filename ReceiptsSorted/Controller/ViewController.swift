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
    
    private let settings = SettingsUserDefaults.shared
    
    
    let warningButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0
        button.tintColor = .systemYellow
        button.setBackgroundImage(UIImage(systemName: "exclamationmark.triangle"), for: .normal)
        button.addTarget(self, action: #selector(warningButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Status Bar
    
    //set Status Bar icons to white
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wetAsphalt
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        DispatchQueue.global(qos: .background).async {
            FileManager.default.cleanTmpDirectory()
        }
        
        if settings.getCurrency().name == nil {
            settings.setDefaultCurrency(to: "£", currencyName: "British Pound Sterling")
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
        
        
        settings.addCurrencyChangedListener(self)
        setupWarningButton()
        
        cardViewController.cardViewModel.showCurrencyWarningSign.onValueChanged { [weak self] showWarning in
            UIView.animate(withDuration: 0.15) {
                self?.warningButton.alpha = (showWarning) ? 1 : 0
            }
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.presentOnboardingIfNeeded(animated: false)

            // Needs to layout first to assign nav transitions to buttonView
            // after it is put into view hiearchy (in queue to be executed once)
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
        
        onStartupActions()
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
        
        var segmentedViewFrame = cardViewController.paymentTypeSegControl.frame
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
    
    
    // MARK: - Warning Button setup
    
    private func setupWarningButton() {
        view.insertSubview(warningButton, at: 1)
        warningButton.translatesAutoresizingMaskIntoConstraints = false
        warningButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        warningButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        warningButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        warningButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    
    
    //MARK: - @IBAction Email button
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        fractionComplete = 0
        cardViewController.selectingPayments(mode: .Enable)
    }
}



// MARK: - CurrencyChangedProtocol
extension ViewController: CurrencyChangedProtocol {

    func currencySettingChanged(to currencySymbol: String, name currencyName: String) {
        topGraphicsView.setCurrencyLabelText(with: currencySymbol)
    }
}

// MARK: - Startup Actions
extension ViewController {
    /// actions to be executed once on startup
    func onStartupActions() {
        if onStartup {
            onStartup = false
            
            // get totalAmount and udate circle indicator graphics
            cardViewController.cardViewModel.database.getTotalAmountAsync(of: .Pending,
                                                                          for: SettingsUserDefaults.shared.getCurrency().name!)
            { totalAmount in
                self.topGraphicsView.amountAnimation.animateCircle(to: totalAmount)
            }
            
            // animate date indicator
            topGraphicsView.dateAnimation.animateToCurrentDate()
            
            // Set push notifications
            pushNotifications.requestAuthorization()
            pushNotifications.getPendingNotificationRequests { [weak self] requests in
                if requests.count == 0 {
                    self?.pushNotifications.schedule(for: SettingsUserDefaults.shared.getIndicatorPeriod())
                }
            }
            
            // Remove receipts older than date
            let removeBeforeMonth = settings.getReceiptRemovalPeriod()
            // If remove receipts settings is enabled (not -1) run command to remove older receipts
            if (removeBeforeMonth > 0) {
                let date = Calendar.current.date(byAdding: .month, value: -removeBeforeMonth, to: Date())!
                cardViewController.cardViewModel.database.removeAllReceipts(olderThan: date) { [unowned self] in
                    self.cardViewController.cardViewModel.refreshPayments()
                }
            }
            // If its a fresh app userdefaults will have 0, change to 6 month
            if removeBeforeMonth == 0 {
                settings.setReceiptRemoval(after: 6)
            }
        }
    }
}


// MARK: - UIPopoverControllerDelegate
extension ViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc private func warningButtonPressed() {
        let popover = WarningPopoverHelper().createWarningPopover(for: warningButton, ofSize: CGSize(width: 200, height: 70))
        popover.popoverPresentationController?.delegate = self
        self.present(popover, animated: true)
    }
}

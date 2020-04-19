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
        amountAnimation.animateCircle(to: totalAmount)
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
    
    
    
    
    //MARK: - Transition animation
    
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
        let topView = UIView()
        
        view.insertSubview(topView, at: 0)
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: cardStartPointY).isActive = true
        
        
        /* Create circles; region is [-pi/2 ; pi*3/2] */
        let mainGraphics = MainGraphicsViewModel(frameWidth: view.frame.size.width, frameHeight: cardStartPointY)
        let contourCircle = mainGraphics.createCircleLine(from: -CGFloat.pi/2, to: CGFloat.pi*3/2, ofColour: UIColor.contourFlatColour.cgColor)
        let indicatorCircle = mainGraphics.createCircleLine(from: -CGFloat.pi/2, to: CGFloat.pi*3/2, ofColour: UIColor.flatOrange.cgColor)
        
        topView.layer.addSublayer(contourCircle)
        topView.layer.addSublayer(indicatorCircle)
        
        contourCircle.applyShadow(color: .black, alpha: 0.16, x: 2, y: 2, blur: 3)
        indicatorCircle.applyShadow(color: .flatOrange, alpha: 0.7, x: 0, y: 1, blur: 6)
        
        
        /* Creating Currency Label inside the circle */
        let currencyLabel = mainGraphics.createCurrencyLabel()
        topView.addSubview(currencyLabel)

        
        
        
        /* Creating Amount sum label that will show sum of all pending payments */
        amountSum = mainGraphics.createLabel()
        topView.addSubview(amountSum)
        
        let offsetRight: CGFloat = 25
        
        amountSum.translatesAutoresizingMaskIntoConstraints = false
        amountSum.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -offsetRight).isActive = true
        amountSum.widthAnchor.constraint(equalTo: topView.widthAnchor, constant: -mainGraphics.circleRightSideOffset-2*offsetRight).isActive = true
        amountSum.heightAnchor.constraint(equalToConstant: 28).isActive = true
        amountSum.centerYAnchor.constraint(equalTo: currencyLabel.centerYAnchor, constant: -mainGraphics.circleRadius*3/4).isActive = true
        
        
        /* Creating "Pending:" UILabel */
        let pendingLabel = mainGraphics.createLabel(text: "Pending:", textAlignment: .left)
        topView.addSubview(pendingLabel)
        
        pendingLabel.translatesAutoresizingMaskIntoConstraints = false
        pendingLabel.rightAnchor.constraint(equalTo: amountSum.rightAnchor).isActive = true
        pendingLabel.heightAnchor.constraint(equalTo: amountSum.heightAnchor).isActive = true
        pendingLabel.widthAnchor.constraint(equalTo: amountSum.widthAnchor).isActive = true
        pendingLabel.centerYAnchor.constraint(equalTo: amountSum.centerYAnchor).isActive = true
        
        
        
        
        let contourBar = mainGraphics.createHorizontalBar(colour: .contourFlatColour, offset: offsetRight)
        let dayBar = mainGraphics.createHorizontalBar(percentage: 0.85, colour: .flatOrange, offset: offsetRight)
        topView.layer.addSublayer(contourBar)
        topView.layer.addSublayer(dayBar)
        contourBar.applyShadow(color: .black, alpha: 0.16, x: 2, y: 2, blur: 3)
        dayBar.applyShadow(color: .flatOrange, alpha: 0.7, x: 0, y: 1, blur: 6)
        
        
        let daysLeftLabel = UILabel(frame: CGRect(x: contourBar.frame.origin.x,
                                                  y: contourBar.frame.origin.y - 25,
                                                  width: contourBar.frame.width,
                                                  height: 17))
        daysLeftLabel.text = "1 out of 7 days left"
        daysLeftLabel.textColor = UIColor(rgb: 0xC6CACE)
        daysLeftLabel.font = UIFont(name: "Arial", size: 15)
        daysLeftLabel.textAlignment = .center
        
        topView.addSubview(daysLeftLabel)
        
        
        
        
        
        amountAnimation = AmountAnimation(animationCircle: indicatorCircle)
        
        amountAnimation.overallAmount.bind {
            self.amountSum.text = "£\($0.ToString(decimals: 2))"
        }
    }
    
    
    
    
    
    
    
    //MARK: - Email button
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: "Send:", message: nil , preferredStyle: .actionSheet)

        let allPendingAction = UIAlertAction(title: "All pending", style: .default, handler: { alert in
            self.showFileFormatAlertSheet()
        })
        let selecteReceiptsAction = UIAlertAction(title: "Select receipts", style: .default, handler: { alert in
            //TODO: Implement expantion and selection
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(allPendingAction)
        optionMenu.addAction(selecteReceiptsAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    private func showFileFormatAlertSheet() {
        let optionMenu = UIAlertController(title: "Send receipts as:", message: nil , preferredStyle: .actionSheet)

        let pdfAction = UIAlertAction(title: "PDF (Table & photos)", style: .default, handler: { alert in
            self.showPDFPreview(for: self.cardViewController.database.fetchSortedData(by: .NewestDateAdded, and: .Pending))
        })
        let archiveAction = UIAlertAction(title: "Archive (Only photos)", style: .default, handler: { alert in
            //TODO: Implement
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(pdfAction)
        optionMenu.addAction(archiveAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    
    private func showPDFPreview(for payments: [Payments]) {
        let pdfPreviewVC = PDFPreviewViewController(nibName: "PDFPreviewViewController", bundle: nil)
        pdfPreviewVC.passedPayments = payments//cardViewController.database.fetchSortedData(by: .NewestDateAdded, and: .Pending)
        pdfPreviewVC.modalPresentationStyle = .overFullScreen
        self.present(pdfPreviewVC, animated: true)
    }
    
}





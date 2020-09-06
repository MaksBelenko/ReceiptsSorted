//
//  CardViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 26/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import CoreData

class CardViewController: UIViewController {
    
    @IBOutlet weak var paymentTypeSegControl: UISegmentedControl!
    @IBOutlet weak var searchAndSortView: UIView!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var selectionHelperView: UIView!
    @IBOutlet weak var bottomSHViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    fileprivate let paymentCellIdentifier = "paymentCell"
    var cardHeight: CGFloat = 0
    var cardStartPointY: CGFloat = 0
    let cardViewModel = CardViewModel()
    var cardGesturesViewModel: CardGesturesViewModel!
    private let dropDownMenu = SortingDropDownMenu()
    private let swipeActions = SwipeActionsViewModel()
    private let userChecker = UserChecker()
    var amountAnimation: AmountAnimation? = nil {
        didSet {
            cardViewModel.amountAnimation = amountAnimation
        }
    }
        
    let noReceiptsImage: UIImageView = {
        guard let optImage = UIImage(named: "NoReceipts") else { return UIImageView() }
        let imageView = UIImageView(image: UIImage(named: "NoReceipts"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    private var emailTipWidthConstraint: NSLayoutConstraint!
    private let emailTipView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.clipsToBounds = true
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let emailTipLabel: UILabel = {
        let label = UILabel()
        label.text = "Select receipts to export and press Next"
        label.font = .arial(ofSize: 13)
        label.textColor = .white
        return label
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteGrayDynColour
        tblView.backgroundColor = .whiteGrayDynColour
        
        configureTableView()
        setupSearchBar()
        setupNoReceiptsImage()
        setupSelectionHelperView()
        sortButton.setTitle(dropDownMenu.getButtonTitle(for: cardViewModel.sortType), for: .normal)
        
        cardViewModel.delegate = self
        setupViewModelBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if  userChecker.wasSwipeDemoShown() == false {
            guard let cell = tblView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PaymentTableViewCell else { return }
            presentSwipeDemo(forCell: cell, animated: false)
            previewSwipeActions(for: cell)
            
            userChecker.setSwipeDemoAsShown() // set UserDefaults as shown
        }
    }
    
    
    // MARK: - ViewModel Bindings
    
    private func setupViewModelBindings() {
        cardViewModel.isSelectionEnabled.onValueChanged { [weak self] selectionEnabled in
            self?.cardViewModel.allSelected = false
            self?.tblView.reloadData()
        }
        
        cardViewModel.selectAllButtonText.onValueChanged { [weak self] (buttonText) in
            self?.selectAllButton.setTitle(buttonText, for: .normal)
        }
        
        cardViewModel.segmentedControlValue.onValueChanged { [weak self] segControlValue in
            guard let self = self else { return }
            self.paymentTypeSegControl.selectedSegmentIndex = segControlValue
            self.segmentedControlValueChanged(self.paymentTypeSegControl)
        }
    }
    
    
    //MARK: - Configurations
    
    private func configureTableView() {
        tblView.dataSource = self
        tblView.delegate = self
        tblView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "paymentCell")
        tblView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) //separator lines
        tblView.tableFooterView = UIView() //Removes uneeded separator lines at the end of TableView
    }
    
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        searchAndSortView.translatesAutoresizingMaskIntoConstraints = false
        searchTopAnchor = searchAndSortView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -(searchAndSortView.frame.size.height))
        searchBottomAnchor = searchAndSortView.bottomAnchor.constraint(equalTo: self.paymentTypeSegControl.topAnchor, constant: -25)
        NSLayoutConstraint.activate([searchTopAnchor!, searchBottomAnchor!])
    }
    
    private func setupNoReceiptsImage() {
        view.addSubview(noReceiptsImage)
        noReceiptsImage.translatesAutoresizingMaskIntoConstraints = false
        noReceiptsImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noReceiptsImage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        noReceiptsImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        
        let offsetY: CGFloat = cardStartPointY/2
        noReceiptImageCenterYAnchor = noReceiptsImage.centerYAnchor.constraint(equalTo: tblView.centerYAnchor, constant: -offsetY)
        noReceiptImageCenterYAnchor?.isActive = true
    }
    
    private func setupSelectionHelperView() {
        configureEmailSelectionTipView() // configures helper view
        
        selectionHelperView.backgroundColor = .whiteGrayDynColour
        selectionHelperView.layer.cornerRadius = 25
        selectionHelperView.layer.applyShadow(color: .blackWhiteShadowColour, alpha: 0.1, x: 0, y: -3, blur: 3)
        selectionHelperView.clipsToBounds = false
        
        bottomSHViewConstraint.isActive = false
        bottomSHViewConstraint = selectionHelperView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: selectionHelperView.frame.height)
        bottomSHViewConstraint.isActive = true
    }
    
    
    // MARK: - Swipe preview setup
    
    private func presentSwipeDemo(forCell cell: PaymentTableViewCell, animated: Bool) {
        let onboardingVC = OnboardingViewController(showWelcomePage: false, addCornerRadius: false)
        let textHelper = TextHelper()
        
        let text = textHelper.create(text: "← Swipe to mark receipt as ", bold: false, fontSize: 18)
        text.append(textHelper.create(text: "Claimed ", bold: true, fontSize: 18))
        text.append(textHelper.create(text: " or to Remove it completely", bold: false, fontSize: 18))
        
        let yOrigin = cell.frame.origin.y + cardStartPointY + paymentTypeSegControl.frame.origin.y + paymentTypeSegControl.frame.height
        let showFrame = CGRect(x: cell.frame.origin.x,
                               y: yOrigin,
                               width: cell.frame.width,
                               height: cell.frame.height - 1)
        
        onboardingVC.add(info: OnboardingInfo(showRect: showFrame, text: text))
        
        onboardingVC.modalPresentationStyle = .overFullScreen
        present(onboardingVC, animated: animated)
    }
    
    
    private func previewSwipeActions(for cell: PaymentTableViewCell) {

        let tickSwipeLabel = createDemoSwipeLabel(text: swipeActions.tickText, backgroundColour: .tickSwipeActionColour)
        let removeSwipeLabel = createDemoSwipeLabel(text: swipeActions.removeText, backgroundColour: .lightRed)

        let removeSwipeWidth: CGFloat = removeSwipeLabel.sizeThatFits(tickSwipeLabel.frame.size).width + 15
        let tickSwipeWidth: CGFloat = tickSwipeLabel.sizeThatFits(tickSwipeLabel.frame.size).width + 15
        
        cell.insertSubview(removeSwipeLabel, belowSubview: cell.contentView)
        removeSwipeLabel.translatesAutoresizingMaskIntoConstraints = false
        removeSwipeLabel.widthAnchor.constraint(equalToConstant: removeSwipeWidth).isActive = true
        removeSwipeLabel.heightAnchor.constraint(equalToConstant: cell.bounds.height).isActive = true
        removeSwipeLabel.trailingAnchor.constraint(equalTo:  cell.trailingAnchor, constant: removeSwipeWidth).isActive = true
        
        cell.insertSubview(tickSwipeLabel, belowSubview: cell.contentView)
        tickSwipeLabel.translatesAutoresizingMaskIntoConstraints = false
        tickSwipeLabel.widthAnchor.constraint(equalToConstant: tickSwipeWidth).isActive = true
        tickSwipeLabel.heightAnchor.constraint(equalToConstant: cell.bounds.height).isActive = true
        tickSwipeLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: removeSwipeWidth + tickSwipeWidth).isActive = true
        
        cell.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: {
            cell.transform = CGAffineTransform.identity.translatedBy(x: -(tickSwipeLabel.bounds.width + removeSwipeLabel.bounds.width),y: 0)
        }) { _ in
            UIView.animateKeyframes(withDuration: 0.3, delay: 3, options: [], animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: { _ in
                tickSwipeLabel.removeFromSuperview()
                removeSwipeLabel.removeFromSuperview()
            })
        }
    }
    
    
    private func createDemoSwipeLabel(text: String, backgroundColour: UIColor) -> UILabel {
        let label = UILabel(frame: CGRect.zero)
        label.text = text
        label.numberOfLines = 0
        label.backgroundColor = backgroundColour
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        return label
    }
    
    
    // MARK: - Email selection helper view
    
    private func configureEmailSelectionTipView() {
        emailTipView.addSubview(emailTipLabel)
        emailTipLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTipLabel.centerXAnchor.constraint(equalTo: emailTipView.centerXAnchor).isActive = true
        emailTipLabel.centerYAnchor.constraint(equalTo: emailTipView.centerYAnchor).isActive = true
        
        view.addSubview(emailTipView)
        emailTipView.translatesAutoresizingMaskIntoConstraints = false
        emailTipView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        emailTipView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        emailTipView.bottomAnchor.constraint(equalTo: selectionHelperView.topAnchor, constant: 5).isActive = true
        
        emailTipWidthConstraint = emailTipView.widthAnchor.constraint(equalToConstant: 0)
        emailTipWidthConstraint.isActive = true
    }
    
    
    private func setEmailTip(to mode: Mode){
        switch mode {
        case .Enable:
            let alphaAppear = setEmailTipContraints(to: .Enable)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.emailTipView.alpha = alphaAppear
            }) { _ in
                let alphaDissapear = self.setEmailTipContraints(to: .Disable)
                UIView.animate(withDuration: 0.5, delay: 5, options: .curveLinear, animations: {
                    self.view.layoutIfNeeded()
                    self.emailTipView.alpha = alphaDissapear
                }, completion: nil)
            }
            
        case .Disable:
            emailTipView.layer.removeAllAnimations()
            emailTipView.subviews.forEach { $0.layer.removeAllAnimations() }
        }
    
    }
    
    
    /// Sets constraints for email tip view and returns alpha for the view
    private func setEmailTipContraints(to mode: Mode) -> CGFloat {
        let alpha: CGFloat
        emailTipWidthConstraint.isActive = false
        switch mode {
        case .Enable:
            alpha = 1
            emailTipWidthConstraint = emailTipView.widthAnchor.constraint(equalTo: emailTipLabel.widthAnchor, constant: 30)
        case .Disable:
            alpha = 0
            emailTipWidthConstraint = emailTipView.widthAnchor.constraint(equalToConstant: 0)
        }
        emailTipWidthConstraint.isActive = true
        
        return alpha
    }
    
    
    
    //MARK: - TableVew Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (fractionComplete > 0 && fractionComplete < 1) ||
               (nextState == .Expanded && fractionComplete < 1) ||
               (nextState == .Collapsed && fractionComplete < 0) {
            tblView.contentOffset.y = 0
        }
        
        if (searchBar.isFirstResponder){
            searchBar.resignFirstResponder()
        }
    }

    
    //MARK: - @IBActions
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        cardViewModel.paymentStatusType = sender.getCurrentPosition()
        cardViewModel.refreshPayments()
    }
    
    
    // ---------------- Selection Helper View ------------------
    @IBAction func nextButtonPressed(_ sender: Any) {
        cardViewModel.getSelectedPayments { [unowned self] selectedPayments in
            if selectedPayments.count == 0 {
                Alert.shared.showNoPaymentsErrorAlert(for: self)
                return
            }
            Alert.shared.showFileFormatAlert(for: self, withPayments: selectedPayments, onComplete: { [unowned self] in
                self.selectingPayments(mode: .Disable)
                self.cardViewModel.selectedPaymentsUIDs.removeAll()
            })
        }
    }
    
    @IBAction func selectAllPressed(_ sender: UIButton) {
        cardViewModel.markAllPayments()
    }
    
    @IBAction func cancelSelectingPressed(_ sender: UIButton) {
        tblView.contentOffset.y = 0
        selectingPayments(mode: .Disable)
        cardViewModel.selectedPaymentsUIDs.removeAll()
    }
    
    
    // MARK: - Selecting payments
    
    func selectingPayments(mode: Mode) {
        setEmailTip(to: mode) // show email tip
        
        cancelButton.isEnabled = false
        cardGesturesViewModel.animateTransitionIfNeeded(with: nextState, for: 0.5, withDampingRatio: 1) {
            self.cancelButton.isEnabled = true // reanable the button once the animation finished
        }
    
        cardViewModel.firstVisibleCells = tblView.visibleCells.map { $0 as! PaymentTableViewCell }
        cardViewModel.isSelectionEnabled.value = (mode == .Enable) ? true : false
        
        bottomSHViewConstraint.isActive = false
        if mode == .Enable {
            bottomSHViewConstraint = selectionHelperView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        } else {
            bottomSHViewConstraint = selectionHelperView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: selectionHelperView.frame.height)
        }
        bottomSHViewConstraint.isActive = true
    }

}



//MARK: - SearchBar extension
extension CardViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        cardViewModel.getPayments(forSearchName: searchText)
    }
}



//MARK: - TableView extension
extension CardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: paymentCellIdentifier, for: indexPath) as! PaymentTableViewCell
        return cardViewModel.setup(cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cardViewModel.tableRowsHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tblView.cellForRow(at: indexPath) as? PaymentTableViewCell else { return }
        
        if cardViewModel.isActionVCNeeded(for: cell, indexPath: indexPath) {
            let selectedPayment = cardViewModel.getPayment(indexPath: indexPath)
            Navigation.shared.showPaymentVC(for: self, payment: selectedPayment)
        }
    }
    
    
    //MARK: - Sections
    
    func numberOfSections(in tableView: UITableView) -> Int {
        noReceiptsImage.alpha = (cardViewModel.numberOfSections == 0) ? 1 : 0
        return cardViewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardViewModel.paymentsCount(for: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return cardViewModel.getSectionHeaderView(for: section, width: view.frame.width)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cardViewModel.headerHeight
    }
    

    
    //MARK: - Slide and remove TableView Cell
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        swipeActions.swipeActionDelegate = self
        tblView.setEditing(false, animated: true)
        let payment = cardViewModel.getPayment(indexPath: indexPath)
        return swipeActions.createTrailingActions(for: indexPath, in: payment)
    }
    
}

// MARK: - RefreshTableDelegate
extension CardViewController: RefreshTableDelegate {
    func reloadTable() {
        tblView.reloadData()
    }

    func updateRows(indexPaths: [IndexPath]) {
        tblView.reloadRows(at: indexPaths, with: .left)
    }
    
    func removeRows(indexPaths: [IndexPath]) {
        tblView.deleteRows(at: indexPaths, with: .right)
    }
    
    func removeSection(indexSet: IndexSet) {
        tblView.deleteSections(indexSet, with: .fade)
    }
}



//MARK: - Sort Popover
extension CardViewController: UIPopoverPresentationControllerDelegate, SortButtonLabelDelegate {
    
    @IBAction func sortButtonPressed(_ sender: UIButton) {
        let popoverPresentationController = dropDownMenu.createDropDownMenu(for: sender, ofSize: CGSize(width: 200, height: 130))
        popoverPresentationController?.delegate = self
        dropDownMenu.sortButtonLabelDelegate = self
        self.present(dropDownMenu.tableViewController, animated: true, completion: nil)
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    
    //Delegate method
    func changeButtonLabel(sortByOption: SortType, buttonTitle: String) {
        if (cardViewModel.sortType != sortByOption) {
            cardViewModel.sortType = sortByOption
            sortButton.setTitle(buttonTitle, for: .normal)
            cardViewModel.refreshPayments()
        }
    }
}


// MARK: - SwipeActionDelegate
extension CardViewController: SwipeActionDelegate {
    
    //Delegate method
    func onSwipeClicked(indexPath: IndexPath, action: SwipeCommandType) {
        let payment = cardViewModel.getPayment(indexPath: indexPath)
        switch action
        {
        case .Remove:
            Alert.shared.showRemoveAlert(for: self, onDelete: { [unowned self] in
                self.cardViewModel.deletePayment(payment: payment, indexPath: indexPath)
            })
            return
        case .Tick:
            cardViewModel.updateField(for: payment, fieldType: .PaymentReceived, with: true) { [unowned self] in
                self.cardViewModel.applyActionToTableView(indexPath: indexPath, action: action)
            }
        case .Untick:
            cardViewModel.updateField(for: payment, fieldType: .PaymentReceived, with: false) { [unowned self] in
                self.cardViewModel.applyActionToTableView(indexPath: indexPath, action: action)
            }
        }
    }
}


// MARK: - TraitCollection
extension CardViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                
                selectionHelperView.layer.shadowColor = UIColor.blackWhiteShadowColour.cgColor
            }
        }
    }
}

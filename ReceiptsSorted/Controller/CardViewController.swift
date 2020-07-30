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
    
    @IBOutlet weak var SortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchAndSortView: UIView!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var selectionHelperView: UIView!
    @IBOutlet weak var bottomSHViewConstraint: NSLayoutConstraint!
    
    
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
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupSearchBar()
        setupNoReceiptsImage()
        setupSelectionHelperView()
        sortButton.setTitle(dropDownMenu.getButtonTitle(for: cardViewModel.sortType), for: .normal)
        
        cardViewModel.delegate = self
        cardViewModel.isSelectionEnabled.onValueChanged { [weak self] selectionEnabled in
            self?.cardViewModel.allSelected = false
            self?.tblView.reloadData()
        }
        
        cardViewModel.selectAllButtonText.onValueChanged { [weak self] (buttonText) in
            self?.selectAllButton.setTitle(buttonText, for: .normal)
        }
        
//        testAddNewPayments()
    }
    
    
//    private func testAddNewPayments() {
//        for i in 0...10000 {
//            cardViewModel.addNewPayment(paymentInfo: PaymentInformation(amountPaid: Float(i), place: "test\(i)", date: Date(), receiptImage: #imageLiteral(resourceName: "NoReceipts")))
//            print("Loop at \(i)")
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if  !userChecker.wasSwipeDemoShown() {
            guard let cell = tblView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PaymentTableViewCell else { return }
            presentSwipeDemo(forCell: cell, animated: false)
            previewSwipeActions(for: cell)
            
            userChecker.setSwipeDemoAsShown() // set UserDefaults as shown
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
    
    
//    func setupDataSource() -> UITableViewDiffableDataSource<String, Payment> {
//      return UITableViewDiffableDataSource(tableView: tblView) { [unowned self] (tableView, indexPath, payment) -> UITableViewCell? in
//        let cell = tableView.dequeueReusableCell(withIdentifier: self.paymentCellIdentifier, for: indexPath) as! PaymentTableViewCell
//        return self.cardVM.setup(cell: cell, with: payment)
//      }
//    }
    
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        searchAndSortView.translatesAutoresizingMaskIntoConstraints = false
        searchTopAnchor = searchAndSortView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -(searchAndSortView.frame.size.height))
        searchBottomAnchor = searchAndSortView.bottomAnchor.constraint(equalTo: self.SortSegmentedControl.topAnchor, constant: -25)
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
        selectionHelperView.layer.cornerRadius = 25
        selectionHelperView.layer.applyShadow(color: .black, alpha: 0.1, x: 0, y: -3, blur: 3)
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
        
        let yOrigin = cell.frame.origin.y + cardStartPointY + SortSegmentedControl.frame.origin.y + SortSegmentedControl.frame.height
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
    
    func selectingPayments(mode: SelectionMode) {
        cardGesturesViewModel.animateTransitionIfNeeded(with: nextState, for: 0.6, withDampingRatio: 1)
    
        cardViewModel.firstVisibleCells = tblView.visibleCells.map{ $0 as! PaymentTableViewCell }
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

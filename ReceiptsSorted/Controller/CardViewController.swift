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
    
    var cardHeight: CGFloat = 0
    var cardStartPointY: CGFloat = 0
    
    let cardViewModel = CardViewModel()
    let dropDownMenu = SortingDropDownMenu()
    let swipeActions = SwipeActionsViewModel()
    var cardGesturesViewModel: CardGesturesViewModel!
    
    var amountAnimation: AmountAnimation? = nil {
        didSet {
            cardViewModel.amountAnimation = amountAnimation
        }
    }
        
    let noReceiptsImage: UIImageView = {
        guard let optImage = UIImage(named: "NoReceipts") else {
            Log.debug(message: "Image not found")
            return UIImageView()
        }
        let imageView = UIImageView(image: UIImage(named: "NoReceipts"))
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        configureTableView()
        setupSearchBar()
        setupNoReceiptsImage()
        setupSelectionHelperView()
        sortButton.setTitle(dropDownMenu.getButtonTitle(for: cardViewModel.sortByOption), for: .normal)
        
        cardViewModel.delegate = self
        cardViewModel.isSelectionEnabled.bind { [weak self] selectionEnabled in
            self?.cardViewModel.allSelected = false
            self?.tblView.reloadData()
        }
        
        cardViewModel.selectAllButtonText.bind { [weak self] (buttonText) in
            self?.selectAllButton.setTitle(buttonText, for: .normal)
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
    
    
    func setupSelectionHelperView() {
        selectionHelperView.layer.cornerRadius = 25
        selectionHelperView.layer.applyShadow(color: .black, alpha: 0.1, x: 0, y: -3, blur: 3)
        selectionHelperView.clipsToBounds = false
        
        bottomSHViewConstraint.isActive = false
        bottomSHViewConstraint = selectionHelperView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: selectionHelperView.frame.height)
        bottomSHViewConstraint.isActive = true
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
        cardViewModel.paymentStatusSort = sender.getCurrentPosition()
        cardViewModel.refreshPayments()
    }
    
    
    // ---------------- Selection Helper View ------------------
    @IBAction func nextButtonPressed(_ sender: Any) {
        let selectedPayments = cardViewModel.getSelectedPayments()
        if selectedPayments.count == 0 {
            Alert.shared.showNoPaymentsErrorAlert(for: self)
            return
        }
        Alert.shared.showFileFormatAlert(for: self, withPayments: selectedPayments)
        cardViewModel.selectedPaymentsUIDs.removeAll()
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
    func changeButtonLabel(sortByOption: SortBy, buttonTitle: String) {
        if (cardViewModel.sortByOption != sortByOption) {
            cardViewModel.sortByOption = sortByOption
            sortButton.setTitle(buttonTitle, for: .normal)
            
            cardViewModel.refreshPayments()
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! PaymentTableViewCell
        return cardViewModel.set(cell: cell, indexPath: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cardViewModel.tableRowsHeight
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tblView.cellForRow(at: indexPath) as? PaymentTableViewCell else { return }
        
        if cardViewModel.selectCellActionShowVC(for: cell, indexPath: indexPath) {
            let selectedPayment = cardViewModel.getPayment(indexPath: indexPath)
            Navigation.shared.showPaymentVC(for: self, payment: selectedPayment)
        }
    }
    
    
    //MARK: - Sections

    func numberOfSections(in tableView: UITableView) -> Int {
        noReceiptsImage.alpha = (cardViewModel.cardTableSections.count == 0) ? 1 : 0
        return cardViewModel.cardTableSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardViewModel.cardTableSections[section].payments.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return cardViewModel.getSectionHeaderView(for: section, width: view.frame.width)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cardViewModel.cardTableHeader.headerHeight
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

// MARK: - SwipeActionDelegate
extension CardViewController: SwipeActionDelegate {
    
    //Delegate method
    func onSwipeClicked(indexPath: IndexPath, action: SwipeCommandType) {
        let payment = cardViewModel.getPayment(indexPath: indexPath)
        switch action
        {
        case .Remove:
            Alert.shared.removePaymentAlert(for: self, payment: payment, indexPath: indexPath)
            return
        case .Tick:
            cardViewModel.database.updateDetail(for: payment, detailType: .PaymentReceived, with: true)
        case .Untick:
            cardViewModel.database.updateDetail(for: payment, detailType: .PaymentReceived, with: false)
        }

        cardViewModel.removeFromTableVeiw(indexPath: indexPath, action: action)
    }
    
    
    //Remove payment Alert calls this
    func deletePayment(payment: Payment, indexPath: IndexPath) {
        self.cardViewModel.database.delete(item: payment)
        cardViewModel.removeFromTableVeiw(indexPath: indexPath, action: .Remove)
    }
    
}






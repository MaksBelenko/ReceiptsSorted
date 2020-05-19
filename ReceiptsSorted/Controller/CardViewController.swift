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
    
    @IBOutlet weak var selectionHelperView: UIView!
    @IBOutlet weak var bottomSHViewConstraint: NSLayoutConstraint!
    
    var cardHeight: CGFloat = 0
    var cardStartPointY: CGFloat = 0
    var tableRowsHeight: CGFloat = 60

    var fetchedPayments: [Payments] = []
    var cardTableSections: [PaymentTableSection] = []
    var paymentUpdateIndex = (section: 0, row: 0)
    
    var sortByOption: SortBy = .NewestDateAdded
    var paymentStatusSort: PaymentStatusSort = .Pending
    
    
    var database = Database()
    let dropDownMenu = SortingDropDownMenu()
    var swipeActions: SwipeActionsViewModel!
    var cardTableViewModel = CardTableViewModel()
    var amountAnimation: AmountAnimation!
    var cardGesturesViewModel: CardGesturesViewModel!
    
    var noReceiptsImage: UIImageView?
    
    var isSelectionEnabled: Bool = false
    var selectedPaymentsUIDs: [UUID] = []
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //Initialise ViewModels
        swipeActions = SwipeActionsViewModel(database: database)
        
        configureTableView()
        setupSearchBar()
        sortButton.setTitle(dropDownMenu.getButtonTitle(for: sortByOption), for: .normal)
        
        fetchedPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
        cardTableSections = cardTableViewModel.getSections(for: fetchedPayments, sortedBy: sortByOption)

        setupNoReceiptsImage()
        setupSelectionHelperView()
    }

    
    
    //MARK: - Configurations
    
    private func configureTableView() {
        tblView.dataSource = self
        tblView.delegate = self
        tblView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "paymentCell")
        
        tblView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) //separator lines full width
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
        noReceiptsImage = UIImageView(image: UIImage(named: "NoReceipts"))
        
        guard let image = noReceiptsImage else {
            Log.debug(message: "Image not found")
            return
        }
        
        image.contentMode = .scaleAspectFit
        view.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        image.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        
        let offsetY: CGFloat = cardStartPointY/2
        noReceiptImageCenterYAnchor = image.centerYAnchor.constraint(equalTo: tblView.centerYAnchor, constant: -offsetY)
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
        paymentStatusSort = sender.getCurrentPosition()
        
        fetchedPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
        cardTableSections = cardTableViewModel.getSections(for: fetchedPayments, sortedBy: sortByOption)
        tblView.reloadData()
    }
    
    
    // ---------------- Selection Helper View ------------------
    @IBAction func nextButtonPressed(_ sender: Any) {
        let selectedPayments = database.fetchData(containsUIDs: selectedPaymentsUIDs)
        Alert.shared.showFileFormatAlert(for: self, withPayments: selectedPayments)
        selectedPaymentsUIDs.removeAll()
    }
    
    
    @IBAction func selectAllPressed(_ sender: UIButton) {
        selectedPaymentsUIDs.removeAll()
        
        for section in 0..<cardTableSections.count {
            for row in 0..<cardTableSections[section].payments.count {
                cellSelectedAction(indexPath: IndexPath(row: row, section: section))
            }
        }
        
    }
    
    
    @IBAction func cancelSelectingPressed(_ sender: UIButton) {
        deselectPaymentsClicked()
    }
    
    
    // MARK: - Selecting payments
    func selectingPaymentsClicked() {
        if nextState == .Expanded {
            cardGesturesViewModel.animateTransitionIfNeeded(with: nextState, for: 0.6, withDampingRatio: 1)
        }
        
        paymentSelection(is: .Enable)
    }
    
    func deselectPaymentsClicked() {
        if nextState == .Collapsed {
            cardGesturesViewModel.animateTransitionIfNeeded(with: nextState, for: 0.6, withDampingRatio: 1)
        }
        
        selectedPaymentsUIDs.removeAll()
        paymentSelection(is: .Disable)
    }
    
    
    // MARK: - Enabling Selection
    func paymentSelection(is status: SelectionMode) {
        isSelectionEnabled = (status == .Enable) ? true : false
        tblView.reloadData()
        
        bottomSHViewConstraint.isActive = false
        if status == .Enable {
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
        if (self.sortByOption != sortByOption) {
            self.sortByOption = sortByOption
            sortButton.setTitle(buttonTitle, for: .normal)
            
            fetchedPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
            cardTableSections = cardTableViewModel.getSections(for: fetchedPayments, sortedBy: sortByOption)
            tblView.reloadData()
        }
    }

}



//MARK: - SearchBar extension
extension CardViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fetchedPayments = database.fetchData(forName: searchText, by: sortByOption, and: paymentStatusSort)  //fetchSortedData(by: sortByOption, and: paymentStatusSort)
        cardTableSections = cardTableViewModel.getSections(for: fetchedPayments, sortedBy: sortByOption)
        tblView.reloadData()
    }
}



//MARK: - TableView extension
extension CardViewController: UITableViewDataSource, UITableViewDelegate, SwipeActionDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let payment = cardTableSections[indexPath.section].payments[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! PaymentTableViewCell
        cell.setCell(for: payment, selectionEnabled: isSelectionEnabled)
        
        if selectedPaymentsUIDs.contains(payment.uid!) {
            cell.selectCell(with: .Tick)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableRowsHeight
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isSelectionEnabled {
            cellSelectedAction(indexPath: indexPath)
            return
        }
        
        // Show PaymentVC
        paymentUpdateIndex = (section: indexPath.section, row: indexPath.row)
        let selectedPayment = cardTableSections[indexPath.section].payments[indexPath.row]
        Navigation.shared.showPaymentVC(for: self, payment: selectedPayment)
    }
    
    
    private func cellSelectedAction(indexPath: IndexPath) {
        let cell = tblView.cellForRow(at: indexPath) as! PaymentTableViewCell
        guard let paymentUID = cardTableSections[indexPath.section].payments[indexPath.row].uid else { return }
        
        if selectedPaymentsUIDs.contains(paymentUID) == false {
            cell.selectCell(with: .Tick)
            selectedPaymentsUIDs.append(paymentUID)
        } else {
            cell.selectCell(with: .Untick)
            let index = selectedPaymentsUIDs.firstIndex(of: paymentUID)!
            selectedPaymentsUIDs.remove(at: index)
        }
    }
    
    
    //MARK: - Sections

    func numberOfSections(in tableView: UITableView) -> Int {
        noReceiptsImage?.alpha = (cardTableSections.count == 0) ? 1 : 0
        return cardTableSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardTableSections[section].payments.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return cardTableViewModel.getSectionHeaderView(for: section, sortedBy: sortByOption, width: view.frame.width)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    

    
    //MARK: - Slide and remove TableView Cell
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        swipeActions.swipeActionDelegate = self
        tblView.setEditing(false, animated: true)
        return swipeActions.createTrailingActions(for: indexPath, in: cardTableSections[indexPath.section].payments[indexPath.row])
    }
    
    //Delegate method
    func onSwipeClicked(indexPath: IndexPath, action: SwipeCommandType) {
        let payment = cardTableSections[indexPath.section].payments[indexPath.row]
        switch action
        {
        case .Remove:
            Alert.shared.removePaymentAlert(for: self, payment: payment, indexPath: indexPath)
            return
        case .Tick:
            database.updateDetail(for: payment, detailType: .PaymentReceived, with: true)
        case .Untick:
            database.updateDetail(for: payment, detailType: .PaymentReceived, with: false)
        }
        
        removeFromTableVeiw(indexPath: indexPath, action: action)
    }
    
    
    private func removeFromTableVeiw(indexPath: IndexPath, action: SwipeCommandType) {
        let payment = cardTableSections[indexPath.section].payments[indexPath.row]
        
        guard let index = fetchedPayments.firstIndex(of: payment) else {
            Log.exception(message: "Mismatch in arrays \"fetchedPayments\" and \"cardTableSections\"")
            return
        }
        
        if (paymentStatusSort != .All || action == .Remove) {
            fetchedPayments.remove(at: index)
            cardTableSections[indexPath.section].payments.remove(at: indexPath.row)
            removeSectionIfEmpty(indexPath: indexPath)
        } else {
            tblView.reloadRows(at: [indexPath], with: .left)
        }
        
        updateCircularBar()
    }
    
    
    private func removeSectionIfEmpty(indexPath: IndexPath) {
        if (cardTableSections[indexPath.section].payments.count == 0) {  //One payments in section
            cardTableSections.remove(at: indexPath.section)
            tblView.deleteSections(IndexSet([indexPath.section]), with: .fade)
        } else {
            tblView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
    //Alert calls this
    func deletePayment(payment: Payments, indexPath: IndexPath) {
        self.database.delete(item: payment)
        removeFromTableVeiw(indexPath: indexPath, action: .Remove)
    }
    
    
    
    private func updateCircularBar() {
        let totalAmount = database.getTotalAmount(of: .Pending)
        amountAnimation.animateCircle(to: totalAmount)
    }
}







//MARK: - PaymentDelegate extension
extension CardViewController: PaymentDelegate {
    
    func passData(as showPayment: ShowPaymentAs, paymentTuple:(amountPaid: Float, place: String, date: Date, receiptImage: UIImage)) {
        DispatchQueue.main.async {
            switch showPayment
            {
                case .AddPayment:
                    let addPayment = self.database.add(payment: paymentTuple)
                    if (self.paymentStatusSort != .Received) {
                        self.fetchedPayments.append(addPayment.payment)
                    }
                    self.amountAnimation.animateCircle(to: addPayment.totalAfter)
                case .UpdatePayment:
                    let payment = self.cardTableSections[self.paymentUpdateIndex.section].payments[self.paymentUpdateIndex.row]
                    guard let index = self.fetchedPayments.firstIndex(of: payment) else {
                        Log.exception(message: "Mismatch in arrays \"fetchedPayments\" and \"cardTableSections\"")
                        return
                    }
                    let updatedPayment = self.database.update(payment: payment, with: paymentTuple)
                    self.fetchedPayments[index] = updatedPayment.payment
                    self.amountAnimation.animateCircle(to: updatedPayment.totalAfter)
                
                    self.database.refault(object: payment.receiptPhoto) // fault receiptData to remove from memory
            }
            
            
//            let fetchedPayments = self.database.fetchSortedData(by: self.sortByOption, and: self.paymentStatusSort)
            self.cardTableSections = self.cardTableViewModel.getSections(for: self.fetchedPayments, sortedBy: self.sortByOption)
            self.tblView.reloadData()
        }
    }
}




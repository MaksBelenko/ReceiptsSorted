//
//  CardViewModel.swift
//  ReceiptsSorted
//
//  Created by Maksim on 21/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit.UIView

class CardViewModel {
    
    weak var delegate: RefreshTableDelegate?
    let database = DatabaseAsync()
    
    // Selection enabled
    var selectAllButtonText: Observable<String> = Observable("Select All")
    var isSelectionEnabled: Observable<Bool> = Observable(false)
    var showCurrencyWarningText: Observable<Bool> = Observable(false)
    var firstVisibleCells: [PaymentTableViewCell] = []
    var selectedPaymentsUIDs = SelectedUIDs()
    
    var tableRowsHeight: CGFloat = 60

    var sortType: SortType = .NewestDateAdded
    var paymentStatusType: PaymentStatusType = .Pending
    var cardTableHeader = CardTableHeader()
    var amountAnimation: AmountAnimation!
    var allSelected = false {
        didSet {
            selectAllButtonText.value = (allSelected) ? "Unselect All" : "Select All"
        }
    }
    
    var headerHeight: CGFloat {
        get { return cardTableHeader.headerHeight }
    }
    
    var numberOfSections: Int {
        get { return cardTableSections.count }
    }
    
    
    private let settings = SettingsUserDefaults.shared
    private var currentSearchText = ""
    private var paymentUpdateIndex = (section: 0, row: 0)
    private var cardTableSections: [PaymentTableSection] = []
    private var fetchedPayments: [Payment] = [] {
        didSet {
            cardTableSections = cardTableHeader.getSections(for: fetchedPayments, sortedBy: sortType)
        }
    }
    
    
    // MARK: - Lifecycle
    init() {
        refreshPayments()
        settings.addCurrencyChangedListener(self)        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceivePaymentData(_:)), name: .didReceivePaymentData, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didReceivePaymentData, object: nil)
    }
    
    
    // MARK: - Helpers
    /**
     Fetches the payments from database and separates them into sections
     */
    func refreshPayments() {
        database.fetchDataAsync(forName: currentSearchText, by: sortType, and: paymentStatusType) { [weak self] payments in
            self?.updateData(with: payments)
        }
    }
    
    /**
     Fetches payments from database that have search name in the names
     - Parameter searchText: Name that is searched for
     */
    func getPayments(forSearchName searchText: String) {
        currentSearchText = searchText
        database.fetchDataAsync(forName: searchText, by: sortType, and: paymentStatusType) { [unowned self] payments in
            self.fetchedPayments = payments
            self.delegate?.reloadTable()
        }
    }
    
    /**
     Updates current payments array with new array
     - Parameter payments: Payments to be updated with
     */
    private func updateData(with payments: [Payment]) {
        fetchedPayments = payments
        delegate?.reloadTable()
        if (isSelectionEnabled.value == true) {
            checkThatAllSelected()
        }
    }
    
    private func loadMoreIfNeeded(indexPath: IndexPath) {
        if (indexPath.section == cardTableSections.count - 1
            && indexPath.row == cardTableSections[indexPath.section].payments.count - 1
            && fetchedPayments.count >= database.fetchLimit)
        {
            database.fetchMoreDataAsync(offset: fetchedPayments.count,
                                        forName: currentSearchText,
                                        by: sortType,
                                        and: paymentStatusType)
            { [unowned self] (count, payments) in
                if count == 0 { return }
                self.fetchedPayments.append(contentsOf: payments)
                self.delegate?.reloadTable()
            }
        }
    }
    
    
    /**
     Gets payment for indexPath
     */
    func getPayment(indexPath: IndexPath) -> Payment {
        return cardTableSections[indexPath.section].payments[indexPath.row]
    }
    
    
    // MARK: - Headers
    
    /**
     Get UIView for section header
     - Parameter section: Section that the header is for
     - Parameter width: Width of the header
     - Returns: UIView for the section header
     */
    func getSectionHeaderView(for section: Int, width: CGFloat) -> UIView {
        return cardTableHeader.getSectionHeaderView(for: section, sortedBy: sortType, width: width)
    }
    
    
    /**
     Gets payments count for a section
     */
    func paymentsCount(for section: Int) -> Int {
        return cardTableSections[section].payments.count
    }
    
    
    // MARK: - Cell methods
    
    /**
     Configures cell
     - Parameter cell: Cell to be configured
     - Parameter indexPath: IndexPath of the cell
     */
    func setup(cell: PaymentTableViewCell, indexPath: IndexPath) -> PaymentTableViewCell {
        loadMoreIfNeeded(indexPath: indexPath)
        
        let payment = getPayment(indexPath: indexPath)
        cell.setCell(for: payment, selectionEnabled: isSelectionEnabled.value, animate: firstVisibleCells.contains(cell))
        
        if selectedPaymentsUIDs.contains(payment.uid!) {
            cell.selectCell(with: .Tick)
        }
        
        return cell
    }
    
    /**
     When cell is selected it determines where the controller should be shown or not
          
    Method checks in view model weather selection is enabled and if not it
    will return true so the PaymentVC can be shown
     - Parameter cell: Cell to be configured
     - Parameter indexPath: IndexPath of the cell
     - Returns: Boolean to show if the controller should be shown or not
     */
    func isActionVCNeeded(for cell: PaymentTableViewCell, indexPath: IndexPath) -> Bool {
        if isSelectionEnabled.value {
            cellSelectedAction(for: cell, indexPath: indexPath)
            return false
        }
        
        paymentUpdateIndex = (section: indexPath.section, row: indexPath.row)
        return true
    }
    
    
    // MARK: - Cell Selection
    
    /**
     Fetches payments from database that returns selected earlier payments from UIDs
     */
    func getSelectedPayments(completion: @escaping ([Payment]) -> ()) {
        database.fetchDataAsync(containingUIDs: selectedPaymentsUIDs.getAll()) { payments in
            completion(payments)
        }
    }
    
    /**
     Either ticks or unticks the cell when in "selectionEnabled" mode
     */
    func cellSelectedAction(for cell: PaymentTableViewCell, indexPath: IndexPath) {
        let payment = getPayment(indexPath: indexPath)
        guard let paymentUID = payment.uid else { return }
        
        if selectedPaymentsUIDs.contains(paymentUID) == false {
            cell.selectCell(with: .Tick)
            selectedPaymentsUIDs.append(paymentUID, for: payment.paymentReceived)
        } else {
            cell.selectCell(with: .Untick)
            selectedPaymentsUIDs.remove(paymentUID)
        }
        
        checkThatAllSelected()
    }
    
    
    /**
     Marks all showing payments as selected
     */
    func markAllPayments() {
        let option: PaymentsSelectionOption = (allSelected) ? .DeselectAll : .SelectAll
        
        switch option {
        case .SelectAll:
            addAllUids(for: paymentStatusType) {
                self.allSelected = !self.allSelected
                self.delegate?.reloadTable()
            }
        
        case .DeselectAll:
            removeUids(for: paymentStatusType)
            self.allSelected = !self.allSelected
            self.delegate?.reloadTable()
            
        }
    }
    
    
    private func addAllUids(for paymentStatus: PaymentStatusType, completion: @escaping () -> ()) {
        switch paymentStatus
        {
        case .All:
            database.getAllUids(for: .Pending) { [unowned self] pendingUIDs in
                self.database.getAllUids(for: .Received) { [unowned self] claimedUIDs in
                    self.selectedPaymentsUIDs.pendingUIDs.append(contentsOf: pendingUIDs)
                    self.selectedPaymentsUIDs.claimedUIDs.append(contentsOf: claimedUIDs)
                    completion()
                }
            }
        case .Pending:
            database.getAllUids(for: paymentStatus) { [unowned self] uids in
                self.selectedPaymentsUIDs.pendingUIDs.append(contentsOf: uids)
                completion()
            }
        case .Received:
            database.getAllUids(for: paymentStatus) { [unowned self] uids in
                self.selectedPaymentsUIDs.claimedUIDs.append(contentsOf: uids)
                completion()
            }
        }
    }
    
    
    private func removeUids(for paymentStatus: PaymentStatusType) {
        switch paymentStatus
        {
        case .All:
            selectedPaymentsUIDs.removeAll()
        case .Pending:
            selectedPaymentsUIDs.pendingUIDs.removeAll()
        case .Received:
            selectedPaymentsUIDs.claimedUIDs.removeAll()
        }
    }
    
    
    private func checkThatAllSelected() {
//        if (selectedPaymentsUIDs.count < fetchedPayments.count) {
//            allSelected = false
//            return
//        }
        
        if fetchedPayments.count == 0 {
            allSelected = false
            return
        }
        
        // Gets the count of the payments which uids match with the ones passed
        database.getUidCount(for: selectedPaymentsUIDs.getAll(), with: paymentStatusType) { [unowned self] uidCount in
            self.database.countPayments(for: self.paymentStatusType) { [unowned self] totalCount in
                DispatchQueue.main.async {
                    self.allSelected = (uidCount == totalCount) ? true : false
                }
            }
        }
    }
}


//MARK: - Notification extension
extension CardViewModel {
    
    @objc private func onReceivePaymentData(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let action = userInfo[NotificationUserInfo.action] as? PaymentAction,
            let paymentInfo = userInfo[NotificationUserInfo.info] as? PaymentInformation else { return }
        
        switch action
        {
        case .AddPayment:
            self.addNewPayment(paymentInfo: paymentInfo)
        case .UpdatePayment:
            self.updatePayment(paymentInfo: paymentInfo)
        }
    }
}


// MARK: - SwipeActionDelegate
extension CardViewModel {
    
    func applyActionToTableView(indexPath: IndexPath, action: SwipeCommandType) {
        let payment = getPayment(indexPath: indexPath)
        
        guard let index = fetchedPayments.firstIndex(of: payment) else {
            Log.exception(message: "Mismatch in arrays \"fetchedPayments\" and \"cardTableSections\"")
            return
        }
        
        if (paymentStatusType != .All || action == .Remove) {
            removeSectionOrRow(indexPath: indexPath, index: index)
        } else {
            delegate?.updateRows(indexPaths: [indexPath])
        }
        
        updateCircularBar()
    }
    
    
    private func removeSectionOrRow(indexPath: IndexPath, index: Int) {
        // Note: Check fist before removing from the fetchedPayments as it
        //       changes cardTableSections in didSet
        let sectionPaymentCount = cardTableSections[indexPath.section].payments.count
        fetchedPayments.remove(at: index)
        if (sectionPaymentCount == 1) {
            delegate?.removeSection(indexSet: IndexSet([indexPath.section]))
        } else {
            delegate?.removeRows(indexPaths: [indexPath])
        }
    }
    
    
    func updateCircularBar() {
        database.getTotalAmountAsync(of: .Pending, for: settings.getCurrency().name!) { totalAmount in
            self.amountAnimation?.animateCircle(to: totalAmount)
        }
    }
    
}





// MARK: - Payment actions
extension CardViewModel {
    
    func addNewPayment(paymentInfo: PaymentInformation) {
        database.addAsync(paymentInfo: paymentInfo) { [weak self] paymentTotalInfo in
            // After concurrently saving context, fetch the payment with the new uid
            self?.database.fetchSinglePaymentAsync(with: paymentTotalInfo.uid) { payment in
                if (self?.paymentStatusType != .Received) {
                    self?.fetchedPayments.append(payment)
                }
                self?.delegate?.reloadTable()
            }
            self?.amountAnimation.animateCircle(to: paymentTotalInfo.totalAfter)
        }
    }
    
    
    private func updatePayment(paymentInfo: PaymentInformation) {
        let payment = cardTableSections[paymentUpdateIndex.section].payments[paymentUpdateIndex.row]
        guard let index = fetchedPayments.firstIndex(of: payment) else {
            Log.exception(message: "Mismatch in arrays \"fetchedPayments\" and \"cardTableSections\"")
            return
        }
        
        database.updateAsync(payment: payment, with: paymentInfo, completion: { info in
            self.database.fetchSinglePaymentAsync(with: info.uid) { payment in
                self.fetchedPayments[index] = payment
                self.database.refault(object: payment.receiptPhoto) // fault receiptData to remove image from memory
                self.delegate?.reloadTable()
            }
            self.amountAnimation.animateCircle(to: info.totalAfter)
        })
    }
    
    
    
    func updateField(for payment: Payment, fieldType: PaymentField, with newDetail: Any, completion: @escaping () -> ()) {
        database.updateFieldAsync(for: payment, fieldType: fieldType, with: newDetail, completion: completion)
    }
    
    
    func deletePayment(payment: Payment, indexPath: IndexPath) {
        database.deleteAsync(item: payment) 
        applyActionToTableView(indexPath: indexPath, action: .Remove)
    }
}



// MARK: - CurrencyChangedProtocol
extension CardViewModel: CurrencyChangedProtocol {
    func currencySettingChanged(to currencySymbol: String, name currencyName: String) {
        updateCircularBar()
        
        database.countDifferentCurrencies(for: paymentStatusType) { [unowned self] currencies in
            print("\(currencies.count) currencies")
            self.showCurrencyWarningText.value = (currencies.count > 1 || !currencies.contains(self.settings.getCurrency().name!)) ? true : false
        }
    }
    
    
}

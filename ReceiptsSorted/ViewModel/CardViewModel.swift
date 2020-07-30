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
    
    // Selection enabled
    var selectAllButtonText: Observable<String> = Observable("Select All")
    var isSelectionEnabled: Observable<Bool> = Observable(false)
    var firstVisibleCells: [PaymentTableViewCell] = []
    var selectedPaymentsUIDs: [UUID] = []
    
    var tableRowsHeight: CGFloat = 60
    
    private var fetchedPayments: [Payment] = [] {
        didSet {
            cardTableSections = cardTableHeader.getSections(for: fetchedPayments, sortedBy: sortType)
        }
    }
    var cardTableSections: [PaymentTableSection] = []
    private var paymentUpdateIndex = (section: 0, row: 0)
    var sortType: SortType = .NewestDateAdded
    var paymentStatusType: PaymentStatusType = .Pending
    var cardTableHeader = CardTableHeader()
    var amountAnimation: AmountAnimation!
    var allSelected = false {
        didSet {
            selectAllButtonText.value = (allSelected) ? "Unselect All" : "Select All"
        }
    }
    
    
    let database = DatabaseAsync()
    private var currentSearchText = ""
    
    // MARK: - Initiliation
    init() {
        refreshPayments()
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
            loadMorePayments()
        }
    }
    
    private func loadMorePayments() {
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
    
    
    
    /**
     Fetches payments from database that returns selected earlier payments from UIDs
     */
    func getSelectedPayments(completion: @escaping ([Payment]) -> ()) {
        database.fetchDataAsync(containingUIDs: selectedPaymentsUIDs) { payments in
            completion(payments)
        }
    }
    
    /**
     Gets payment for indexPath
     */
    func getPayment(indexPath: IndexPath) -> Payment {
        return cardTableSections[indexPath.section].payments[indexPath.row]
    }
    
    
    // MARK: - Header
    
    /**
     Get UIView for section header
     - Parameter section: Section that the header is for
     - Parameter width: Width of the header
     - Returns: UIView for the section header
     */
    func getSectionHeaderView(for section: Int, width: CGFloat) -> UIView {
        return cardTableHeader.getSectionHeaderView(for: section, sortedBy: sortType, width: width)
    }
    
    
    
    // MARK: - Cell methods
    
    /**
     Configures cell
     - Parameter cell: Cell to be configured
     - Parameter indexPath: IndexPath of the cell
     */
    func set(cell: PaymentTableViewCell, indexPath: IndexPath) -> PaymentTableViewCell {
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
    func selectCellActionShowVC(for cell: PaymentTableViewCell, indexPath: IndexPath) -> Bool {
        if isSelectionEnabled.value {
            cellSelectedAction(for: cell, indexPath: indexPath)
            return false
        }
        
        paymentUpdateIndex = (section: indexPath.section, row: indexPath.row)
        return true
    }
    
    
    // MARK: - Cell Selection
    /**
     Either ticks or unticks the cell when in "selectionEnabled" mode
     */
    func cellSelectedAction(for cell: PaymentTableViewCell, indexPath: IndexPath) {
        guard let paymentUID = getPayment(indexPath: indexPath).uid else { return }
        
        if selectedPaymentsUIDs.contains(paymentUID) == false {
            cell.selectCell(with: .Tick)
            selectedPaymentsUIDs.append(paymentUID)
        } else {
            cell.selectCell(with: .Untick)
            let index = selectedPaymentsUIDs.firstIndex(of: paymentUID)!
            selectedPaymentsUIDs.remove(at: index)
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
//            database.getAllUids(for: paymentStatusType) { uids in
//                
//            }
            
            fetchedPayments.forEach {
                if (!selectedPaymentsUIDs.contains($0.uid!)) {
                    selectedPaymentsUIDs.append($0.uid!)
                }
            }
            selectAllButtonText.value = "Unselect All"
        
        case .DeselectAll:
            fetchedPayments.forEach {
                if selectedPaymentsUIDs.contains($0.uid!) {
                    let index = selectedPaymentsUIDs.firstIndex(of: $0.uid!)
                    selectedPaymentsUIDs.remove(at: index!)
                }
            }
            selectAllButtonText.value = "Select All"
        }
        
        allSelected = !allSelected
        delegate?.reloadTable()
    }
    
    
    private func checkThatAllSelected() {
        if selectedPaymentsUIDs.count < fetchedPayments.count {
            allSelected = false
            return
        }
        
        var count = 0
        for fetchedPayment in fetchedPayments {
            for selectedUid in selectedPaymentsUIDs {
                if fetchedPayment.uid == selectedUid {
                    count += 1
                }
            }
        }
        
        allSelected = (count == fetchedPayments.count) ? true : false
       
    }
    
    
    // MARK: - Delete Payment
    
    func deletePayment(payment: Payment, indexPath: IndexPath) {
        database.deleteAsync(item: payment)
        applyActionToTableView(indexPath: indexPath, action: .Remove)
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
        database.getTotalAmountAsync(of: .Pending) { totalAmount in
            self.amountAnimation?.animateCircle(to: totalAmount)
        }
    }
    
}

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
    
    
    // MARK: - Initiliation
    init() {
        refreshPayments()
    }
    
    
    
    // MARK: - Helpers
    /**
     Fetches the payments from database and separates them into sections
     */
    func refreshPayments() {
        database.fetchDataAsync(by: sortType, and: paymentStatusType) { [weak self] payments in
            self?.updateData(with: payments)
        }
    }
    
    /**
     Updates current payments array with bew array
     - Parameter payments: Payments to be updated with
     */
    private func updateData(with payments: [Payment]) {
        fetchedPayments = payments
        delegate?.reloadTable()
        if (isSelectionEnabled.value == true) {
            checkThatAllSelected()
        }
    }
    
    /**
     Fetches payments from database that have search name in the names
     - Parameter searchText: Name that is searched for
     */
    func getPayments(forSearchName searchText: String) {
        database.fetchDataAsync(forName: searchText, by: sortType, and: paymentStatusType) { [unowned self] payments in
            self.fetchedPayments = payments
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
        removeFromTableVeiw(indexPath: indexPath, action: .Remove)
    }
}


//MARK: - PaymentDelegate extension
extension CardViewModel: PaymentDelegate {
    
    // ----- Delegate method -----
    func passData(as showPayment: PaymentAction, paymentInfo: PaymentInformation) {
        switch showPayment
        {
        case .AddPayment:
            self.addNewPayment(paymentInfo: paymentInfo)
        case .UpdatePayment:
            self.updatePayment(paymentInfo: paymentInfo)
        }
    }
    
    
    private func addNewPayment(paymentInfo: PaymentInformation) {
        database.addAsync(paymentInfo: paymentInfo) { [weak self] paymentTotalInfo in

            // After concurrently saving context, fetch the payment with the new uid
            self?.database.fetchPaymentAsync(with: paymentTotalInfo.uid) { payment in
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
            self.database.fetchPaymentAsync(with: info.uid) { payment in
                self.fetchedPayments[index] = payment
                self.database.refault(object: payment.receiptPhoto) // fault receiptData to remove image from memory
                self.delegate?.reloadTable()
            }
            self.amountAnimation.animateCircle(to: info.totalAfter)
        })
    }
    
    
    
    func updateField(for payment: Payment, fieldType: PaymentField, with newDetail: Any) {
        database.updateFieldAsync(for: payment, fieldType: fieldType, with: newDetail)
    }
}


// MARK: - SwipeActionDelegate
extension CardViewModel {
    
    func removeFromTableVeiw(indexPath: IndexPath, action: SwipeCommandType) {
        let payment = getPayment(indexPath: indexPath)
        
        guard let index = fetchedPayments.firstIndex(of: payment) else {
            Log.exception(message: "Mismatch in arrays \"fetchedPayments\" and \"cardTableSections\"")
            return
        }
        
        if (paymentStatusType != .All || action == .Remove) {
            removeSectionIfEmpty(indexPath: indexPath, index: index)
        } else {
            delegate?.updateRows(indexPaths: [indexPath])
        }
        
        updateCircularBar()
    }
    
    
    private func removeSectionIfEmpty(indexPath: IndexPath, index: Int) {
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

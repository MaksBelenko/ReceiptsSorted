//
//  CardViewModel.swift
//  ReceiptsSorted
//
//  Created by Maksim on 21/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit.UIView

class CardViewModel {
    
    var tableRowsHeight: CGFloat = 60
    
    var fetchedPayments: [Payments] = []
    var cardTableSections: [PaymentTableSection] = []
    var paymentUpdateIndex = (section: 0, row: 0)
    
    var sortByOption: SortBy = .NewestDateAdded
    var paymentStatusSort: PaymentStatusSort = .Pending
    
    var database = DatabaseAdapter()
    var cardTableHeader = CardTableHeader()
    var amountAnimation: AmountAnimation!
    
    // Selection enabled
    var isSelectionEnabled: Observable<Bool> = Observable(false)
    var selectedPaymentsUIDs: [UUID] = []
    
    weak var delegate: RefreshTableDelegate?
    
    
    
    // MARK: - Initiliation
    init() {
        refreshPayments(reloadTable: false)
    }
    
    
    // MARK: - Helpers
    /**
     Fetches the payments from database and separates them into sections
     - Parameter reloadTable: Causes to delegate reloadTable() method to be fired when set to true
     */
    func refreshPayments(reloadTable: Bool = true) {
        fetchedPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
        cardTableSections = cardTableHeader.getSections(for: fetchedPayments, sortedBy: sortByOption)
        if (reloadTable) {
            delegate?.reloadTable()
        }
    }
    
    /**
     Fetches payments from database that have search name in the names
     - Parameter searchText: Name that is searched for
     */
    func getPayments(forSearchName searchText: String) {
        fetchedPayments = database.fetchData(forName: searchText, by: sortByOption, and: paymentStatusSort)
        cardTableSections = cardTableHeader.getSections(for: fetchedPayments, sortedBy: sortByOption)
        delegate?.reloadTable()
    }
    
    /**
     Fetches payments from database that returns selected earlier payments from UIDs
     */
    func getSelectedPayments() -> [Payments] {
        return database.fetchData(containsUIDs: selectedPaymentsUIDs)
    }
    
    /**
     Gets payment for indexPath
     */
    func getPayment(indexPath: IndexPath) -> Payments {
        return cardTableSections[indexPath.section].payments[indexPath.row]
    }
    
    
    /**
     Get UIView for section header
     - Parameter section: Section that the header is for
     - Parameter width: Width of the header
     - Returns: UIView for the section header
     */
    func getSectionHeaderView(for section: Int, width: CGFloat) -> UIView {
        return cardTableHeader.getSectionHeaderView(for: section, sortedBy: sortByOption, width: width)
    }
    
    
    
    // MARK: - Cell methods
    
    /**
     Configures cell
     - Parameter cell: Cell to be configured
     - Parameter indexPath: IndexPath of the cell
     */
    func set(cell: PaymentTableViewCell, indexPath: IndexPath) -> PaymentTableViewCell {
        let payment = getPayment(indexPath: indexPath)
        cell.setCell(for: payment, selectionEnabled: isSelectionEnabled.value)
        
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
    
    

}


//MARK: - PaymentDelegate extension
extension CardViewModel: PaymentDelegate {
    
    // ----- Delegate method -----
    func passData(as showPayment: ShowPaymentAs, paymentInfo: PaymentInformation) {
        DispatchQueue.main.async {
            switch showPayment
            {
                case .AddPayment:
                    self.addNewPayment(paymentInfo: paymentInfo)
                case .UpdatePayment:
                    self.updatePayment(paymentInfo: paymentInfo)
            }
            
            self.cardTableSections = self.cardTableHeader.getSections(for: self.fetchedPayments, sortedBy: self.sortByOption)
            self.delegate?.reloadTable()
        }
    }
    
    
    private func addNewPayment(paymentInfo: PaymentInformation) {
        let addPayment = database.add(payment: paymentInfo)
        if (paymentStatusSort != .Received) {
            fetchedPayments.append(addPayment.payment)
        }
        amountAnimation.animateCircle(to: addPayment.totalAfter)
    }
    
    
    private func updatePayment(paymentInfo: PaymentInformation) {
        let payment = cardTableSections[paymentUpdateIndex.section].payments[paymentUpdateIndex.row]
        guard let index = fetchedPayments.firstIndex(of: payment) else {
            Log.exception(message: "Mismatch in arrays \"fetchedPayments\" and \"cardTableSections\"")
            return
        }
        let updatedPayment = database.update(payment: payment, with: paymentInfo)
        fetchedPayments[index] = updatedPayment.payment
        amountAnimation.animateCircle(to: updatedPayment.totalAfter)
        
        database.refault(object: payment.receiptPhoto) // fault receiptData to remove from memory
    }
}


// MARK: - SwipeActionDelegate
extension CardViewModel{
    
       func removeFromTableVeiw(indexPath: IndexPath, action: SwipeCommandType) {
        let payment = getPayment(indexPath: indexPath)
            
            guard let index = fetchedPayments.firstIndex(of: payment) else {
                Log.exception(message: "Mismatch in arrays \"fetchedPayments\" and \"cardTableSections\"")
                return
            }
            
            if (paymentStatusSort != .All || action == .Remove) {
                fetchedPayments.remove(at: index)
                cardTableSections[indexPath.section].payments.remove(at: indexPath.row)
                removeSectionIfEmpty(indexPath: indexPath)
            }
            else {
                delegate?.updateRows(indexPaths: [indexPath])
            }
            
            updateCircularBar()
        }
        
        
        private func removeSectionIfEmpty(indexPath: IndexPath) {
            if (cardTableSections[indexPath.section].payments.count == 0) {  //One payments in section
                cardTableSections.remove(at: indexPath.section)
                delegate?.removeSection(indexSet: IndexSet([indexPath.section]))
            }
            else {
                delegate?.removeRows(indexPaths: [indexPath])
            }
        }
    
    
    func updateCircularBar() {
        let totalAmount = database.getTotalAmount(of: .Pending)
        amountAnimation?.animateCircle(to: totalAmount)
    }
    
}

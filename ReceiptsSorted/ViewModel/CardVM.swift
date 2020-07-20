//
//  CardVM.swift
//  ReceiptsSorted
//
//  Created by Maksim on 20/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit.UIView

class CardVM {

    let db = DatabaseAsync()

    var sortType: SortType = .NewestDateAdded
    var paymentStatusType: PaymentStatusType = .Pending


    var isSelectionEnabled: Observable<Bool> = Observable(false)
    var firstVisibleCells: [PaymentTableViewCell] = []
    var selectedPaymentsUIDs: [UUID] = []


    // MARK: - Initiliation
    init() {
//        refreshPayments(reloadTable: false)
    }



    /**
     Configures cell
     - Parameter cell: Cell to be configured
     - Parameter indexPath: IndexPath of the cell
     */
    func set(cell: PaymentTableViewCell, with payment: Payment) -> PaymentTableViewCell {
        cell.setCell(for: payment, selectionEnabled: isSelectionEnabled.value, animate: firstVisibleCells.contains(cell) )

        if selectedPaymentsUIDs.contains(payment.uid!) {
            cell.selectCell(with: .Tick)
        }

        return cell
    }

}

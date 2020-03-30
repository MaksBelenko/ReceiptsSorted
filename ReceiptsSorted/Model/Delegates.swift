//
//  PopupDelegate.swift
//  ReceiptsSorted
//
//  Created by Maksim on 29/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit


protocol PopupDelegate {
    func setAmountPaidValue(value: Float)
    func setPlaceValue(value: String)
    func setDatepopupValue(value: Date)
}


protocol PaymentDelegate {
    func passData(as showPayment: ShowPaymentAs, paymentTuple:(amountPaid: Float, place: String, date: Date, receiptImage: UIImage))
}

protocol SortButtonLabelDelegate {
    func changeButtonLabel(sortByOption: SortBy, buttonTitle: String)
}

protocol SwipeActionDelegate {
    func onSwipeClicked(indexPath: IndexPath)
}

//
//  PopupDelegate.swift
//  ReceiptsSorted
//
//  Created by Maksim on 29/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit


protocol PopupDelegate: AnyObject {
    func setAmountPaidValue(value: Float)
    func setPlaceValue(value: String)
    func setDatepopupValue(value: Date)
}


protocol PaymentDelegate: AnyObject {
    func passData(as showPayment: ShowPaymentAs, paymentTuple:(amountPaid: Float, place: String, date: Date, receiptImage: UIImage))
}

protocol SortButtonLabelDelegate: AnyObject {
    func changeButtonLabel(sortByOption: SortBy, buttonTitle: String)
}

protocol SwipeActionDelegate: AnyObject {
    func onSwipeClicked(indexPath: IndexPath, action: SwipeCommandType)
}

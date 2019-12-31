//
//  PopupDelegate.swift
//  ReceiptsSorted
//
//  Created by Maksim on 29/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit


protocol PopupDelegate {
    func setAmountPaidValue(value: String)
    func setPlaceValue(value: String)
    func setDatepopupValue(value: String)
}


protocol PaymentDelegate {
    func passData(amountPaid: String, place: String, date: String, receiptImage: UIImage)
}

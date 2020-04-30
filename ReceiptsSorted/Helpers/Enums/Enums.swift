//
//  Enums.swift
//  ReceiptsSorted
//
//  Created by Maksim on 26/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//


enum CardState {
    case Expanded, Collapsed
}

enum ShowPaymentAs {
    case AddPayment, UpdatePayment
}

enum PaymentDetail {
    case Image, AmountPaid, Place, PaymentReceived
}

enum TableColumn {
    case Date, Place, Price
}

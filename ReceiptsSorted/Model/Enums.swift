//
//  Enums.swift
//  ReceiptsSorted
//
//  Created by Maksim on 26/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//


enum ImageSource {
    case photoLibrary
    case camera
}

enum CardState {
    case Expanded, Collapsed
}

enum PopupType {
    case AmountPaid, Place
}

enum ShowPaymentAs {
    case AddPayment, UpdatePayment
}

enum CircularTransitionMode:Int {
    case present, dismiss, pop
}

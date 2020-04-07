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

enum CircularTransitionMode {
    case present, dismiss, pop
}

enum SortBy {
    case OldestDateAdded, NewestDateAdded, Place, None
}

enum PaymentStatusSort {
    case Pending, Received, All
}

enum SwipeCommandType {
    case Remove, Tick, Untick
}

enum PaymentDetail {
    case Image, AmountPaid, Place, PaymentReceived
}

enum Alignment {
    case left, centre, right
}

enum TableColumn {
    case Date, Place, Price
}

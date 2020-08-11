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

enum PaymentAction {
    case AddPayment, UpdatePayment
}

enum PaymentField {
    case Image, AmountPaid, Place, PaymentReceived
}

enum TableColumn {
    case Date, Place, Price
}

enum SwipeCommandType {
    case Remove, Tick, Untick
}

enum ShareImagesType {
    case RawImages, Zip
}

enum Mode {
    case Enable, Disable
}

enum SelectionAction {
    case Tick, Untick
}

enum PaymentsSelectionOption {
    case SelectAll, DeselectAll
}

enum NotificationUserInfo: String {
    case action = "action"
    case info = "info"
}

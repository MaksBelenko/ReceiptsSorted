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

protocol SortButtonLabelDelegate: AnyObject {
    func changeButtonLabel(sortByOption: SortType, buttonTitle: String)
}

protocol SwipeActionDelegate: AnyObject {
    func onSwipeClicked(indexPath: IndexPath, action: SwipeCommandType)
}

protocol RefreshTableDelegate: AnyObject {
    func reloadTable()
    func updateRows(indexPaths: [IndexPath])
    func removeRows(indexPaths: [IndexPath])
    func removeSection(indexSet: IndexSet)
}


//
//  SwipeActions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 07/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class SwipeActionsViewModel {

    var swipeActionDelegate: SwipeActionDelegate?
    
    
    /**
     Creates "Tick/Untick" and "Remove" trailing actions
     - Parameter itemNumber: Index of the item to perform trailing actions for
     - Parameter payments: List of payments
     */
    func createTrailingActions(for indexPath: IndexPath, in payments: [Payments]) -> UISwipeActionsConfiguration {
        
        let checkAction:UIContextualAction?
        
        let deleteAction = createContextualAction(title: "Remove", colour: UIColor.red, indexPath: indexPath) { (indexPath) in
            self.deleteItem(for: indexPath)
        }
        
        if (payments[indexPath.row].paymentReceived == false){
            checkAction = createContextualAction(title: "Received", colour: UIColor(rgb: 0x3498db), indexPath: indexPath, onSelectAction: { (indexPath) in
                self.tickItem(for: indexPath)
            })
        } else {
            checkAction = createContextualAction(title: "Not Received", colour: UIColor.gray, indexPath: indexPath, onSelectAction: { (indexPath) in
                self.unTickItem(for: indexPath)
            })
        }
        
//        deleteAction.image = UIImage(named: "Remove_50x50")
//        deleteAction.image = UIImage(systemName: "xmark")
//        checkAction.image = UIImage(systemName: "checkmark.circle")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, checkAction!])
    }
    
    
    private func createContextualAction(title: String, colour: UIColor, indexPath: IndexPath, onSelectAction: @escaping (IndexPath) -> ()) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: title) {  (action, view, complete) in
            complete(true)
            onSelectAction(indexPath)
        }
        action.backgroundColor = colour
        
        return action
    }
    
    
    
    private func deleteItem(for indexPath: IndexPath) {
        swipeActionDelegate?.onSwipeClicked(swipeCommand: .Remove, indexPath: indexPath)
    }
    
    private func tickItem(for indexPath: IndexPath) {
        swipeActionDelegate?.onSwipeClicked(swipeCommand: .Tick, indexPath: indexPath)
    }
    private func unTickItem(for indexPath: IndexPath) {
        swipeActionDelegate?.onSwipeClicked(swipeCommand: .Untick, indexPath: indexPath)
    }
}

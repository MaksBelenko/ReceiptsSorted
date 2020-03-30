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
    var database: Database!
    
    
    init(database: Database) {
        self.database = database
    }
    
    
    
    /**
     Creates "Tick/Untick" and "Remove" trailing actions
     - Parameter itemNumber: Index of the item to perform trailing actions for
     - Parameter payments: List of payments
     */
    func createTrailingActions(for indexPath: IndexPath, in payment: Payments) -> UISwipeActionsConfiguration {
        
        let checkAction:UIContextualAction?
        
        let deleteAction = createContextualAction(title: "Remove", colour: UIColor.red, indexPath: indexPath) { (indexPath) in
            self.actionClicked(for: .Remove, indexPath: indexPath, payment: payment)
        }
        
        if (payment.paymentReceived == false){
            checkAction = createContextualAction(title: "Received", colour: UIColor(rgb: 0x3498db), indexPath: indexPath, onSelectAction: { (indexPath) in
                self.actionClicked(for: .Tick, indexPath: indexPath, payment: payment)
            })
        } else {
            checkAction = createContextualAction(title: "Not Received", colour: UIColor.gray, indexPath: indexPath, onSelectAction: { (indexPath) in
                self.actionClicked(for: .Untick, indexPath: indexPath, payment: payment)
            })
        }
        
//        deleteAction.image = UIImage(named: "Remove_50x50")
//        deleteAction.image = UIImage(systemName: "xmark")
//        checkAction.image = UIImage(systemName: "checkmark.circle")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, checkAction!])
    }
    

    
    
    
    
    
    func actionClicked(for swipeCommand: SwipeCommandType, indexPath: IndexPath, payment: Payments) {
            switch swipeCommand
            {
            case .Remove:
                database.delete(item: payment)
            case .Tick:
                database.updateDetail(for: payment, detailType: .PaymentReceived, with: true)
            case .Untick:
                database.updateDetail(for: payment, detailType: .PaymentReceived, with: false)
            }
        
        swipeActionDelegate?.onSwipeClicked(indexPath: indexPath)
    }
    
    
    
    
    
    
    /**
     Creates UIContextualAction for the tableView cell
     - Parameter title: The title of the action button
     - Parameter colour: The colour of the action button
     - Parameter indexPath: IndexPath of the tableView cell that is passed to closure
     - Parameter onSelectAction: Closure that is executed once action button is pressed
     */
    private func createContextualAction(title: String, colour: UIColor, indexPath: IndexPath, onSelectAction: @escaping (IndexPath) -> ()) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: title) {  (action, view, complete) in
            complete(true)
            onSelectAction(indexPath)
        }
        action.backgroundColor = colour
        
        return action
    }
    
}

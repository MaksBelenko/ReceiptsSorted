//
//  SwipeActions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 07/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class SwipeActions {
    
    /**
     Creates "Tick/Untick" and "Remove" trailing actions
     - Parameter itemNumber: Index of the item to perform trailing actions for
     - Parameter payments: List of payments
     */
    func createTrailingActions(for indexPath: IndexPath, in payments: [Payments]) -> UISwipeActionsConfiguration {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") {  (action, view, nil) in
            self.deleteItem(in: payments, for: indexPath)
        }
        
        let checkAction = UIContextualAction(style: .normal, title: "Received") {  (action, view, nil) in
            self.tickItem(in: payments, for: indexPath)
        }
        
        deleteAction.backgroundColor = UIColor.red
        checkAction.backgroundColor = UIColor(rgb: 0x3498db)  //Flat UI Color "Light blue"
        
//        deleteAction.image = UIImage(named: "Remove_50x50")
//        deleteAction.image = UIImage(systemName: "xmark")
//        checkAction.image = UIImage(systemName: "checkmark.circle")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, checkAction])
    }
    
    
    
    
    private func deleteItem(in payments: [Payments], for indexPath: IndexPath) {
//        database.delete(item: payments[indexPath.row])
//        payments.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    private func tickItem(in payments: [Payments], for indexPath: IndexPath) {
        
    }
}

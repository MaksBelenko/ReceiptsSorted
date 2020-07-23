//
//  SwipeActions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 07/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class SwipeActionsViewModel {

    weak var swipeActionDelegate: SwipeActionDelegate?
    
    let removeText = "\u{2715}\nRemove"  //\u{2716}
    let tickText = "\u{2713}\nClaimed"
    
    
    /**
     Creates "Tick/Untick" and "Remove" trailing actions
     - Parameter indexPath: Index of the item to perform trailing actions for
     - Parameter payments: List of payments
     */
    func createTrailingActions(for indexPath: IndexPath, in payment: Payment) -> UISwipeActionsConfiguration {
        
        let checkAction:UIContextualAction?
        
        let deleteAction = createContextualAction(title: removeText, colour: .lightRed, indexPath: indexPath) { (indexPath) in
            self.actionClicked(for: .Remove, indexPath: indexPath, payment: payment)
        }
        
        if (payment.paymentReceived == false){
            checkAction = createContextualAction(title: tickText, colour: .tickSwipeActionColour, indexPath: indexPath, onSelectAction: { (indexPath) in
                self.actionClicked(for: .Tick, indexPath: indexPath, payment: payment)
            })
        } else {
            checkAction = createContextualAction(title: "Not\n Claimed", colour: .graySwipeColour, indexPath: indexPath, onSelectAction: { (indexPath) in
                self.actionClicked(for: .Untick, indexPath: indexPath, payment: payment)
            })
        }
        
        return UISwipeActionsConfiguration(actions: [checkAction!, deleteAction])
    }
    

    
    
    func actionClicked(for swipeCommand: SwipeCommandType, indexPath: IndexPath, payment: Payment) {
        swipeActionDelegate?.onSwipeClicked(indexPath: indexPath, action: swipeCommand)
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
            view.tintColor = .white
            complete(true)
            onSelectAction(indexPath)
        }
        
//        let a = action as! UIButton
        action.backgroundColor = colour
        
        return action
    }
    
}

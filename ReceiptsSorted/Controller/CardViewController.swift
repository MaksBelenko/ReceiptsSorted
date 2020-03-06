//
//  CardViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 26/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import CoreData

class CardViewController: UIViewController {

    @IBOutlet weak var sortButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var handleImageView: UIImageView!
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    var cardHeight: CGFloat = 0
    var tableRowsHeight: CGFloat = 60

    var payments: [Payments] = []
    var database = Database()

    var paymentUpdateIndex = 0
    
    let dropDownMenu = SortingDropDownMenu()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        payments = database.loadPayments()
        
        tblView.dataSource = self
        tblView.delegate = self
        tblView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "paymentCell")
        
        // Used to make separators lines full width
        tblView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //Removes uneeded separator lines at the end of TableView
        tblView.tableFooterView = UIView()
        
        // Set TableView height
        tblView.frame.size.height = cardHeight * 4/5
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
    }

    
    
    
    //MARK: - TableVew Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("fr = \(fractionComplete)")
//        print("vel = \(scrollView.panGestureRecognizer.velocity(in: self.tblView).y)")
        if ((fractionComplete > 0 && fractionComplete < 1) || (nextState == .Expanded && fractionComplete < 1)) {
            tblView.contentOffset.y = 0
        }
    }
    
}


extension CardViewController: UIPopoverPresentationControllerDelegate {
    @IBAction func sortButtonPressed(_ sender: UIButton) {
        
        let popoverPresentationController = dropDownMenu.createDropDownMenu(for: sender, ofSize: CGSize(width: 90, height: 130))
        popoverPresentationController?.delegate = self
        
        self.present(dropDownMenu.tableViewController, animated: true, completion: nil)
    }
    
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}



//MARK: - SearchBar extension
extension CardViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        payments = database.fetchData(forName: searchText)
        tblView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // start animation if cardView is minimised
    }
}



//MARK: - TableView extension
extension CardViewController: UITableViewDataSource, UITableViewDelegate {
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return payments.count
        }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let p = payments[indexPath.row]
                 
            let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! PaymentTableViewCell
            
            cell.amountPaidText.text = p.amountPaid!
            cell.placeText.text = p.place!
            cell.dateText.text = p.date!
            cell.receivedPayment = p.paymentReceived
            
            
            if (p.paymentReceived == true) {
                cell.tickLabel.backgroundColor = UIColor(rgb: 0x3498db).withAlphaComponent(1)
                cell.tickLabel.text = "✓"
            } else {
                cell.tickLabel.backgroundColor = UIColor(rgb: 0x3498db).withAlphaComponent(0)
                cell.tickLabel.text = ""
            }
            
            return cell
        }
        
        
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return tableRowsHeight
        }
        
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let selectedPayment = payments[indexPath.row]
            paymentUpdateIndex = indexPath.row
            
            if let paymentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetails") as? PaymentViewController
            {
                paymentVC.passedImage = UIImage(data: selectedPayment.receiptPhoto ?? Data())
                paymentVC.amountPaid = selectedPayment.amountPaid!
                paymentVC.place = selectedPayment.place!
                paymentVC.date = selectedPayment.date!
                paymentVC.pageType = .UpdatePayment
                
                paymentVC.paymentDelegate = self
                
                paymentVC.modalPresentationStyle = .fullScreen
                self.present(paymentVC, animated: true, completion: nil)
            }
                
        }
        
        
        
        //MARK: - Slide and remove TableView Cell
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            
            if (payments[indexPath.row].paymentReceived == true) {
                return false
            }
            
            return true
        }

        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

            if (editingStyle == .delete) {
                payments[indexPath.row].paymentReceived = true
                database.saveContext()
                //reload row and then data for animation
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.reloadData()
    
//                database.delete(item: payments[indexPath.row])
//                payments.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }


        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            
            let contextItem = UIContextualAction(style: .destructive, title: "✓") {  (contextualAction, view, boolValue) in
                self.tblView.dataSource?.tableView!(self.tblView, commit: .delete, forRowAt: indexPath)
                return
            }

            contextItem.backgroundColor = UIColor(rgb: 0x3498db)  //Flat UI Color "Light blue"
            let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])

            return swipeActions
        }
}


//MARK: - PaymentDelegate extension
extension CardViewController: PaymentDelegate {
    
    func passData(amountPaid: String, place: String, date: String, receiptImage: UIImage) {
        
//        payments[paymentUpdateIndex].receiptPhoto = receiptImage.jpegData(compressionQuality: 1)
        payments[paymentUpdateIndex].amountPaid = amountPaid
        payments[paymentUpdateIndex].place = place
        payments[paymentUpdateIndex].date = date
        
        database.saveContext()
        tblView.reloadData()
    }
}


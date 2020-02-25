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
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var handleImageView: UIImageView!
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    var cardHeight: CGFloat = 0
    var tableRowsHeight: CGFloat = 60

    var payments: [Payments] = []
    var database = Database()

    var paymentUpdateIndex = 0
    
    // An empty tuple that will be updated with search results.
    var searchResults : [(title: String, image: String)] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        payments = database.loadPayments()
        
        
        //Removes uneeded separator lines at the end of TableView
        tblView.tableFooterView = UIView()
        
        tblView.dataSource = self
        tblView.delegate = self
        tblView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "paymentCell")
        
        // Used to make separators lines full width
        tblView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Set TableView height
        tblView.frame.size.height = cardHeight * 4/5
        
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
//        searchBar.showsCancelButton = true
        
//
//        searchController.searchResultsUpdater = self
//        self.definesPresentationContext = true
//
//        // Place the search bar in the table view's header.
//        self.tblView.tableHeaderView = searchController.searchBar
//
//        // Set the content offset to the height of the search bar's height
//        // to hide it when the view is first presented.
//        self.tblView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
//
//
        
        //searchBar.isHidden = false
        

//        tblView.showsVerticalScrollIndicator = false
//        tblView.isScrollEnabled = false
    }

    
//    func updateSearchResults(for searchController: UISearchController) {
//        // If the search bar contains text, filter our data with the string
//        if let searchText = searchController.searchBar.text {
//            filterContent(for: searchText)
//            // Reload the table view with the search result data.
//            tblView.reloadData()
//        }
//    }
//
//
//    func filterContent(for searchText: String) {
//        // Update the searchResults array with matches
//        // in our entries based on the title value.
////        let search = payments.filter({ (name) -> Bool in
//////            let match = name.range(of: searchText, options: .caseInsensitive)
////            // Return the tuple if the range contains a match.
//////            return match != nil
////        })
//    }
    
    
    
    
    //MARK: - TableVew Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("fr = \(fractionComplete)")
//        print("vel = \(scrollView.panGestureRecognizer.velocity(in: self.tblView).y)")
        if ((fractionComplete > 0 && fractionComplete < 1) || (nextState == .Expanded && fractionComplete < 1)) {
            tblView.contentOffset.y = 0
        }
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
            return true
        }

        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

            if (editingStyle == .delete) {
                database.delete(item: payments[indexPath.row])
                payments.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
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


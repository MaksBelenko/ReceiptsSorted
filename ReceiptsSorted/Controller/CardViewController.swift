//
//  CardViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 26/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import CoreData

var searchTopAnchor: NSLayoutConstraint?

class CardViewController: UIViewController {
    
    @IBOutlet weak var SortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchAndSortView: UIView!
    
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
    let swipeActions = SwipeActions()
    
    var sortByOption: SortBy = .NewestDateAdded
    var paymentStatusSort: PaymentStatusSort = .Pending
    
    var names: [String] = ["March", "April"]
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        payments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
        
        tblView.dataSource = self
        tblView.delegate = self
        tblView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "paymentCell")
        
        // Used to make separators lines full width
        tblView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //Removes uneeded separator lines at the end of TableView
        tblView.tableFooterView = UIView()
        
        // Set TableView height
        tblView.frame.size.height = cardHeight * 3/5
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        
        searchAndSortView.translatesAutoresizingMaskIntoConstraints = false
        searchTopAnchor = searchAndSortView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -11)
        searchTopAnchor!.isActive = true
        
        setButtonTitle(for: sortByOption)
    }

    
    
    
    //MARK: - TableVew Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("fr = \(fractionComplete)")
//        print("vel = \(scrollView.panGestureRecognizer.velocity(in: self.tblView).y)")
        if ((fractionComplete > 0 && fractionComplete < 1) || (nextState == .Expanded && fractionComplete < 1)) {
            print("fractionComplete = \(fractionComplete)")
            tblView.contentOffset.y = 0
        }
    }

    
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            paymentStatusSort = .Pending
        case 1:
            paymentStatusSort = .Received
        case 2:
            paymentStatusSort = .All
        default:
            break
        }
        
        payments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
        tblView.reloadData()
    }
    
    
}



//MARK: - Sort Popover
extension CardViewController: UIPopoverPresentationControllerDelegate, SortButtonLabelDelegate {
    
    @IBAction func sortButtonPressed(_ sender: UIButton) {
        
        let popoverPresentationController = dropDownMenu.createDropDownMenu(for: sender, ofSize: CGSize(width: 200, height: 130))
        popoverPresentationController?.delegate = self
        dropDownMenu.sortButtonLabelDelegate = self
        
        self.present(dropDownMenu.tableViewController, animated: true, completion: nil)
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    
    func changeButtonLabel(sortByOption: SortBy) {
        
        if (self.sortByOption != sortByOption) {
            self.sortByOption = sortByOption
            setButtonTitle(for: sortByOption)
            payments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
            tblView.reloadData()
        }
    }
    
    func setButtonTitle(for sortTitle: SortBy) {
        switch sortTitle
        {
        case .Place:
            sortButton.setTitle("Place", for: .normal)
        case .NewestDateAdded:
            sortButton.setTitle("Date ↓", for: .normal)
        case .OldestDateAdded:
            sortButton.setTitle("Date ↑", for: .normal)
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
extension CardViewController: UITableViewDataSource, UITableViewDelegate, SwipeActionDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! PaymentTableViewCell
        cell.setCell(for: payments[indexPath.row])
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
            paymentVC.amountPaid = selectedPayment.amountPaid
            paymentVC.place = selectedPayment.place!
            paymentVC.date = selectedPayment.date!
            paymentVC.pageType = .UpdatePayment
            
            paymentVC.paymentDelegate = self
            
            paymentVC.modalPresentationStyle = .fullScreen
            self.present(paymentVC, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Sections

//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return names[section]
//    }
//
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return names
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2 //sections.count // or sortedFirstLetters.count
//    }


    
    //MARK: - Slide and remove TableView Cell
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if (editingStyle == .delete) {
            if (payments[indexPath.row].paymentReceived == false) {
                payments[indexPath.row].paymentReceived = true
                database.saveContext()
                //reload row and then data for animation
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.reloadData()
            } else {
                database.delete(item: payments[indexPath.row])
                payments.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }


        }
    }


    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        swipeActions.swipeActionDelegate = self
        return swipeActions.createTrailingActions(for: indexPath, in: payments)
    }
    
    func onSwipeClicked(swipeCommand: SwipeCommandType, indexPath: IndexPath) {
        switch swipeCommand
        {
        case .Remove:
            database.delete(item: payments[indexPath.row])
            payments.remove(at: indexPath.row)
            tblView.deleteRows(at: [indexPath], with: .automatic)
        case .Tick:
            payments[indexPath.row].paymentReceived = true
            database.saveContext()
            //reload row and then data for animation
            //tblView.reloadRows(at: [indexPath], with: .none)
            tblView.reloadData()
        case .Untick:
            payments[indexPath.row].paymentReceived = false
            database.saveContext()
            //reload row and then data for animation
            //tblView.reloadRows(at: [indexPath], with: .none)
            tblView.reloadData()
        }
    }

}


//MARK: - PaymentDelegate extension
extension CardViewController: PaymentDelegate {
    
    func passData(amountPaid: Float, place: String, date: Date, receiptImage: UIImage) {
        
        payments[paymentUpdateIndex].receiptPhoto = receiptImage.jpegData(compressionQuality: 1)
        payments[paymentUpdateIndex].amountPaid = amountPaid
        payments[paymentUpdateIndex].place = place
        payments[paymentUpdateIndex].date = date
        
        database.saveContext()
        tblView.reloadData()
    }
}


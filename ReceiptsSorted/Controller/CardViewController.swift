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

    var showingPayments: [Payments] = []
    var sections: [PaymentTableSection] = []
    var paymentUpdateIndex = 0
    
    var sortByOption: SortBy = .NewestDateAdded
    var paymentStatusSort: PaymentStatusSort = .Pending
    
    var database = Database()
    let dropDownMenu = SortingDropDownMenu()
    let swipeActions = SwipeActionsViewModel()
    var cardTableViewModel = CardTableViewModel()
    

    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        showingPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
        
        setupTableView()
        setupSearchBar()
        setButtonTitle(for: sortByOption)
        
    }

    
    func setupTableView() {
        tblView.dataSource = self
        tblView.delegate = self
        tblView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "paymentCell")
        
        // Used to make separators lines full width
//        tblView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tblView.separatorStyle = .none
        //Removes uneeded separator lines at the end of TableView
        tblView.tableFooterView = UIView()
        
        // Set TableView height
        tblView.frame.size.height = cardHeight * 3/5
        
    }
    
    
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        searchAndSortView.translatesAutoresizingMaskIntoConstraints = false
        searchTopAnchor = searchAndSortView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -11)
        searchTopAnchor!.isActive = true
    }
    
    
    
    //MARK: - TableVew Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ((fractionComplete > 0 && fractionComplete < 1) || (nextState == .Expanded && fractionComplete < 1)) {
            tblView.contentOffset.y = 0
        }
        
        if (searchBar.isFirstResponder){
            searchBar.resignFirstResponder()
        }
    }

    
    
    
    //MARK: - Segmented Control
    
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
        
        showingPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
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
    
    
    //Delegate method
    func changeButtonLabel(sortByOption: SortBy) {
        if (self.sortByOption != sortByOption) {
            self.sortByOption = sortByOption
            setButtonTitle(for: sortByOption)
            showingPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
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
        showingPayments = database.fetchData(forName: searchText)
        tblView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // start animation if cardView is minimised
    }
}



//MARK: - TableView extension
extension CardViewController: UITableViewDataSource, UITableViewDelegate, SwipeActionDelegate {

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! PaymentTableViewCell
        cell.setCell(for: sections[indexPath.section].payments[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableRowsHeight
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedPayment = showingPayments[indexPath.row]
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

    func numberOfSections(in tableView: UITableView) -> Int {
        sections = cardTableViewModel.getSections(for: showingPayments, sortedBy: sortByOption)
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].payments.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return cardTableViewModel.getSectionHeaderView(for: section, sortedBy: sortByOption, width: view.frame.width)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? 30 : 40
    }
    

    
    //MARK: - Slide and remove TableView Cell
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        swipeActions.swipeActionDelegate = self
        tblView.setEditing(false, animated: true)
        return swipeActions.createTrailingActions(for: indexPath, in: showingPayments)
    }
    
    
    func onSwipeClicked(swipeCommand: SwipeCommandType, indexPath: IndexPath) {
        switch swipeCommand
        {
        case .Remove:
            database.delete(item: showingPayments[indexPath.row])
            showingPayments.remove(at: indexPath.row)
            tblView.deleteRows(at: [indexPath], with: .fade)
        case .Tick:
            showingPayments[indexPath.row].paymentReceived = true
            database.saveContext()
            if (paymentStatusSort != .All) {
                showingPayments.remove(at: indexPath.row)
                tblView.deleteRows(at: [indexPath], with: .right)
            } else {
//                (tblView.cellForRow(at: [indexPath.row]) as! PaymentTableViewCell).tickLabel.text = "✓"
//                tblView.reloadData()
//                tblView.reloadRows(at: [indexPath], with: .right)
            }
        case .Untick:
            showingPayments[indexPath.row].paymentReceived = false
            database.saveContext()
            if (paymentStatusSort != .All) {
                showingPayments.remove(at: indexPath.row)
                tblView.deleteRows(at: [indexPath], with: .left)
            } else {
//                (tblView.cellForRow(at: [indexPath.row]) as! PaymentTableViewCell).tickLabel.text = ""
//                tblView.reloadData()
//                tblView.reloadRows(at: [indexPath], with: .right)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        print("Finished")
        guard let indexPath = indexPath else {return}
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}



//MARK: - PaymentDelegate extension
extension CardViewController: PaymentDelegate {
    
    func passData(amountPaid: Float, place: String, date: Date, receiptImage: UIImage) {
        
        showingPayments[paymentUpdateIndex].receiptPhoto = receiptImage.jpegData(compressionQuality: 1)
        showingPayments[paymentUpdateIndex].amountPaid = amountPaid
        showingPayments[paymentUpdateIndex].place = place
        showingPayments[paymentUpdateIndex].date = date
        
        database.saveContext()
        tblView.reloadData()
    }
}




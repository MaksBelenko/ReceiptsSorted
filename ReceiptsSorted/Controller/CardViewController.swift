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
    
    @IBOutlet weak var SortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchAndSortView: UIView!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var handleImageView: UIImageView!
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    
    var cardHeight: CGFloat = 0
    var tableRowsHeight: CGFloat = 60

    var cardTableSections: [PaymentTableSection] = []
    var paymentUpdateIndex = (section: 0, row: 0)
    
    var sortByOption: SortBy = .NewestDateAdded
    var paymentStatusSort: PaymentStatusSort = .Pending
    
    var database = Database()
    let dropDownMenu = SortingDropDownMenu()
    var swipeActions: SwipeActionsViewModel!
    var cardTableViewModel = CardTableViewModel()
    
    var amountAnimation: AmountAnimation!
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //Initialise ViewModels
        swipeActions = SwipeActionsViewModel(database: database)
        
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        setupTableView()
        setupSearchBar()
        sortButton.setTitle(dropDownMenu.getButtonTitle(for: sortByOption), for: .normal)
        
        let fetchedPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
        cardTableSections = cardTableViewModel.getSections(for: fetchedPayments, sortedBy: sortByOption)
//        setButtonTitle(for: sortByOption)
        
    }

    
    func setupTableView() {
        tblView.dataSource = self
        tblView.delegate = self
        tblView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "paymentCell")
        
        // Used to make separators lines full width
        tblView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
//        tblView.separatorStyle = .none
        //Removes uneeded separator lines at the end of TableView
        tblView.tableFooterView = UIView()
        
        // Set TableView height
        tblView.frame.size.height = cardHeight * 1/5
        
    }
    
    
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        searchAndSortView.translatesAutoresizingMaskIntoConstraints = false
        searchTopAnchor = searchAndSortView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -(searchAndSortView.frame.size.height))
        searchBottomAnchor = searchAndSortView.bottomAnchor.constraint(equalTo: self.SortSegmentedControl.topAnchor, constant: -25)
        
        NSLayoutConstraint.activate([searchTopAnchor!, searchBottomAnchor!])
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
        
        let fetchedPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
        cardTableSections = cardTableViewModel.getSections(for: fetchedPayments, sortedBy: sortByOption)
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
    func changeButtonLabel(sortByOption: SortBy, buttonTitle: String) {
        if (self.sortByOption != sortByOption) {
            self.sortByOption = sortByOption
            sortButton.setTitle(buttonTitle, for: .normal)
            
            let fetchedPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
            cardTableSections = cardTableViewModel.getSections(for: fetchedPayments, sortedBy: sortByOption)
            tblView.reloadData()
        }
    }

}



//MARK: - SearchBar extension
extension CardViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let fetchedPayments = database.fetchData(forName: searchText, by: sortByOption, and: paymentStatusSort)  //fetchSortedData(by: sortByOption, and: paymentStatusSort)
        cardTableSections = cardTableViewModel.getSections(for: fetchedPayments, sortedBy: sortByOption)
        tblView.reloadData()
    }
}



//MARK: - TableView extension
extension CardViewController: UITableViewDataSource, UITableViewDelegate, SwipeActionDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! PaymentTableViewCell
        cell.setCell(for: cardTableSections[indexPath.section].payments[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableRowsHeight
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedPayment = cardTableSections[indexPath.section].payments[indexPath.row]
        paymentUpdateIndex = (section: indexPath.section, row: indexPath.row)
        
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
//        let fetchedPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
//        cardTableSections = cardTableViewModel.getSections(for: fetchedPayments, sortedBy: sortByOption)
        return cardTableSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardTableSections[section].payments.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return cardTableViewModel.getSectionHeaderView(for: section, sortedBy: sortByOption, width: view.frame.width)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return (section == 0) ? 20 : 30
        return 40
    }
    

    
    //MARK: - Slide and remove TableView Cell
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        swipeActions.swipeActionDelegate = self
        tblView.setEditing(false, animated: true)
        return swipeActions.createTrailingActions(for: indexPath, in: cardTableSections[indexPath.section].payments[indexPath.row])
    }
    
    
    func onSwipeClicked(indexPath: IndexPath) {
        if (paymentStatusSort != .All) {
            cardTableSections[indexPath.section].payments.remove(at: indexPath.row)
            tblView.deleteRows(at: [indexPath], with: .fade)
        } else {
            tblView.reloadRows(at: [indexPath], with: .left)
        }
    }
    
    func removeEntryOrSection(indexPath: IndexPath) {
        if (cardTableSections[indexPath.section].payments.count == 1) {  //One payments in section
//            cardTableSections.remove(at: indexPath.section)
            cardTableSections[indexPath.section].payments.remove(at: indexPath.row)
            tblView.reloadData()//deleteSections(IndexSet([indexPath.section]), with: .fade)
        } else {
            cardTableSections[indexPath.section].payments.remove(at: indexPath.row)
            tblView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
//    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
//        print("Finished")
//        guard let indexPath = indexPath else {return}
//        tblView.deleteRows(at: [indexPath], with: .left)
//    }
}







//MARK: - PaymentDelegate extension
extension CardViewController: PaymentDelegate {
    
    func passData(as showPayment: ShowPaymentAs, paymentTuple:(amountPaid: Float, place: String, date: Date, receiptImage: UIImage)) {
        DispatchQueue.main.async {
            switch showPayment
            {
                case .AddPayment:
                    let totalTuple = self.database.add(payment: paymentTuple)
                    self.amountAnimation.animateCircle(from: totalTuple.totalBefore, to: totalTuple.totalAfter)
                case .UpdatePayment:
                    self.database.update(payment: self.cardTableSections[self.paymentUpdateIndex.section].payments[self.paymentUpdateIndex.row], with: paymentTuple)
            }
            
            self.tblView.reloadData()
        }
    }
}




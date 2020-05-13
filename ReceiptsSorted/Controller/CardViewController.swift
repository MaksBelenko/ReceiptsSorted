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
    @IBOutlet weak var tblView: UITableView!
    
    
    var cardHeight: CGFloat = 0
    var cardStartPointY: CGFloat = 0
    var tableRowsHeight: CGFloat = 60

    var fetchedPayments: [Payments] = []
    var cardTableSections: [PaymentTableSection] = []
    var paymentUpdateIndex = (section: 0, row: 0)
    
    var sortByOption: SortBy = .NewestDateAdded
    var paymentStatusSort: PaymentStatusSort = .Pending
    
    var database = Database()
    let dropDownMenu = SortingDropDownMenu()
    var swipeActions: SwipeActionsViewModel!
    var cardTableViewModel = CardTableViewModel()
    var amountAnimation: AmountAnimation!
    
    var noReceiptsImage: UIImageView?
    
    
    
    //MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //Initialise ViewModels
        swipeActions = SwipeActionsViewModel(database: database)
        
        configureTableView()
        setupSearchBar()
        sortButton.setTitle(dropDownMenu.getButtonTitle(for: sortByOption), for: .normal)
        
        fetchedPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
        cardTableSections = cardTableViewModel.getSections(for: fetchedPayments, sortedBy: sortByOption)
//        setButtonTitle(for: sortByOption)
        
        setupNoReceiptsImage()
    }

    
    
    //MARK: - Configurations
    
    private func configureTableView() {
        tblView.dataSource = self
        tblView.delegate = self
        tblView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "paymentCell")
        
        tblView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) //separator lines full width
        tblView.tableFooterView = UIView() //Removes uneeded separator lines at the end of TableView
    }
    
    
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        searchAndSortView.translatesAutoresizingMaskIntoConstraints = false
        searchTopAnchor = searchAndSortView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -(searchAndSortView.frame.size.height))
        searchBottomAnchor = searchAndSortView.bottomAnchor.constraint(equalTo: self.SortSegmentedControl.topAnchor, constant: -25)
        
        NSLayoutConstraint.activate([searchTopAnchor!, searchBottomAnchor!])
    }
    
    
    private func setupNoReceiptsImage() {
        noReceiptsImage = UIImageView(image: UIImage(named: "NoReceipts"))
        
        guard let image = noReceiptsImage else {
            Log.debug(message: "Image not found")
            return
        }
        
        image.contentMode = .scaleAspectFit
        view.addSubview(image)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        image.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        
        let offsetY: CGFloat = cardStartPointY/2
        noReceiptImageCenterYAnchor = image.centerYAnchor.constraint(equalTo: tblView.centerYAnchor, constant: -offsetY)
        noReceiptImageCenterYAnchor?.isActive = true
    }
    
    
    
    //MARK: - TableVew Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (fractionComplete > 0 && fractionComplete < 1) ||
               (nextState == .Expanded && fractionComplete < 1) ||
                (nextState == .Collapsed && fractionComplete < 0) {
            tblView.contentOffset.y = 0
        }
        
        if (searchBar.isFirstResponder){
            searchBar.resignFirstResponder()
        }
    }

    
    
    
    //MARK: - Segmented Control
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        paymentStatusSort = sender.getCurrentPosition()
        
        fetchedPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
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
            
            fetchedPayments = database.fetchSortedData(by: sortByOption, and: paymentStatusSort)
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
        fetchedPayments = database.fetchData(forName: searchText, by: sortByOption, and: paymentStatusSort)  //fetchSortedData(by: sortByOption, and: paymentStatusSort)
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
            Log.debug(message: "size in MB = \(Float(selectedPayment.receiptPhoto!.count) / powf(10, 6))")
            
            paymentVC.amountPaid = selectedPayment.amountPaid
            paymentVC.place = selectedPayment.place!
            paymentVC.date = selectedPayment.date!
            paymentVC.pageType = .UpdatePayment
            
            paymentVC.paymentDelegate = self
            
            paymentVC.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(paymentVC, animated: true)
//            self.present(paymentVC, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Sections

    func numberOfSections(in tableView: UITableView) -> Int {
        noReceiptsImage?.alpha = (cardTableSections.count == 0) ? 1 : 0
        return cardTableSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardTableSections[section].payments.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return cardTableViewModel.getSectionHeaderView(for: section, sortedBy: sortByOption, width: view.frame.width)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
    
    //Delegate method
    func onSwipeClicked(indexPath: IndexPath, action: SwipeCommandType) {
        let payment = cardTableSections[indexPath.section].payments[indexPath.row]
        switch action
        {
        case .Remove:
            removePaymentAlert(indexPath: indexPath, action: action)
//            database.delete(item: payment)
            return
        case .Tick:
            database.updateDetail(for: payment, detailType: .PaymentReceived, with: true)
        case .Untick:
            database.updateDetail(for: payment, detailType: .PaymentReceived, with: false)
        }
        
        removeFromTableVeiw(indexPath: indexPath, action: action)
    }
    
    
    private func removeFromTableVeiw(indexPath: IndexPath, action: SwipeCommandType) {
        if (paymentStatusSort != .All || action == .Remove) {
            cardTableSections[indexPath.section].payments.remove(at: indexPath.row)
            removeSectionIfEmpty(indexPath: indexPath)
        } else {
            tblView.reloadRows(at: [indexPath], with: .left)
        }
    }
    
    
    private func removeSectionIfEmpty(indexPath: IndexPath) {
        if (cardTableSections[indexPath.section].payments.count == 0) {  //One payments in section
            cardTableSections.remove(at: indexPath.section)
            tblView.deleteSections(IndexSet([indexPath.section]), with: .fade)
        } else {
            tblView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    // MARK: - CardView Alerts
    
    func removePaymentAlert(indexPath: IndexPath, action: SwipeCommandType) {
        Vibration.light.vibrate()
        
        let optionMenu = UIAlertController(title: "Are you sure you want to delete the payment?", message: nil , preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Yes, delete", style: .destructive, handler: { alert in
            let payment = self.cardTableSections[indexPath.section].payments[indexPath.row]
            self.database.delete(item: payment)
            guard let index = self.fetchedPayments.firstIndex(of: payment) else {
                Log.exception(message: "Mismatch in arrays \"fetchedPayments\" and \"cardTableSections\"")
                return
            }
            self.fetchedPayments.remove(at: index)
            self.cardTableSections[indexPath.section].payments.remove(at: indexPath.row)
            self.removeSectionIfEmpty(indexPath: indexPath)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
}







//MARK: - PaymentDelegate extension
extension CardViewController: PaymentDelegate {
    
    func passData(as showPayment: ShowPaymentAs, paymentTuple:(amountPaid: Float, place: String, date: Date, receiptImage: UIImage)) {
        DispatchQueue.main.async {
            switch showPayment
            {
                case .AddPayment:
                    let addPayment = self.database.add(payment: paymentTuple)
                    if (self.paymentStatusSort != .Received) {
                        self.fetchedPayments.append(addPayment.payment)
                    }
                    self.amountAnimation.animateCircle(from: addPayment.totalBefore, to: addPayment.totalAfter)
                case .UpdatePayment:
                    let payment = self.cardTableSections[self.paymentUpdateIndex.section].payments[self.paymentUpdateIndex.row]
                    guard let index = self.fetchedPayments.firstIndex(of: payment) else {
                        Log.exception(message: "Mismatch in arrays \"fetchedPayments\" and \"cardTableSections\"")
                        return
                    }
                    let updatedPayment = self.database.update(payment: payment, with: paymentTuple)
                    self.fetchedPayments[index] = updatedPayment.payment
                    self.amountAnimation.animateCircle(from: updatedPayment.totalBefore, to: updatedPayment.totalAfter)
            }
            
            
//            let fetchedPayments = self.database.fetchSortedData(by: self.sortByOption, and: self.paymentStatusSort)
            self.cardTableSections = self.cardTableViewModel.getSections(for: self.fetchedPayments, sortedBy: self.sortByOption)
            self.tblView.reloadData()
        }
    }
}




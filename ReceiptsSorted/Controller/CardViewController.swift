//
//  CardViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 26/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import CoreData

class CardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var handleImageView: UIImageView!
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    var cardHeight: CGFloat = 0
    var tableRowsHeight: CGFloat = 60

    var payments: [Payments] = []
    var database = Database()

    var paymentUpdateIndex = 0
    
    
    
    
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
        
//        tblView.showsVerticalScrollIndicator = false
//        tblView.isScrollEnabled = false
    }

    
    
    //MARK: - TableView Methods for cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! PaymentTableViewCell

        let p = payments[indexPath.row]
        
        cell.amountPaidText.text = p.amountPaid!
        cell.placeText.text = p.place!
        cell.dateText.text = p.date!
//        cell.receiptImageView.image =
        
        
        //print("\(cell.amountPaidText.text!)  \(cell.dateText.text!)")
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
    

    
    
    
    //MARK: - TableVew Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("fr = \(fractionComplete)")
        print("vel = \(scrollView.panGestureRecognizer.velocity(in: self.tblView).y)")
        if ((fractionComplete > 0 && fractionComplete < 1) || (nextState == .Expanded && fractionComplete < 1)) {
            tblView.contentOffset.y = 0
        }
    }
    
}



//MARK: - Extension for PaymentDelegate
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

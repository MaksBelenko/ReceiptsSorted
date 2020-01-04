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

    typealias Payment = (String, String, String, UIImage)
    var payments: [Payments] = []
    //var payments: [Payment] = [("£13.00", "Dominos","Paid on 20 August 2019", UIImage(named: "Receipt-Test")!),
//                               ("£35.25", "Champneys","Paid on 19 August 2019", UIImage(named: "Receipt-Test")!)]
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //Removes uneeded separator lines at the end of TableView
        tblView.tableFooterView = UIView()
        
        //tableView.isUserInteractionEnabled = false
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

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! PaymentTableViewCell

        let p = payments[indexPath.row]
        
        cell.amountPaidText.text = p.amountPaid! + "  (" + p.place! + ")"
        cell.dateText.text = p.date!
//        cell.receiptImageView.image =
        
//        cell.amountPaidText.text = payments[indexPath.row].0 + " (" + payments[indexPath.row].1 + ")"
//        cell.dateText.text = payments[indexPath.row].2
//        cell.receiptImageView.image = payments[indexPath.row].3
        
        // Set to make separator lines to be of full width
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero
        
        
        //print("\(cell.amountPaidText.text!)  \(cell.dateText.text!)")
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableRowsHeight
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("row selected at \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
            
    }
    
    
    
    
    //MARK: - Table Scroll Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scroll")

        let scrollViewHeight = scrollView.frame.size.height;
        let scrollContentSizeHeight = scrollView.contentSize.height;
        let scrollOffset = scrollView.contentOffset.y;

        if (scrollOffset == 0)
        {
            // then we are at the top
//            print("at the top")
        }
        else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
        {
            // then we are at the end
//            print("at the bottom")
        }
        
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        print("reached top")
        //tblView.isUserInteractionEnabled = false
    }
    
    
    
    
    //MARK: - Slide and remove TableView Cell
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if (editingStyle == .delete) {
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
    
    
    
    
    
    
    
    
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error found: \(error)")
        }
    }
    
}


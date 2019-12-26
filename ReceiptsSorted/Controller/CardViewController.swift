//
//  CardViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 26/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit

class CardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var handleImageView: UIImageView!
    @IBOutlet weak var handleArea: UIView!
    
    @IBOutlet weak var tblView: UITableView!
    
    var tableRowsHeight: CGFloat = 60

    
    typealias Payment = (Float, String)
    var payments: [Payment] = [(13,"Paid on 20th of August 2019"),
                               (22,"Paid on 20th of August 2019"),
                               (21,"Paid on 20th of August 2019"),
                               (24,"Paid on 20th of August 2019"),
                               (22,"Paid on 19th of August 2019"),
                               (21,"Paid on 19th of August 2019"),
                               (24,"Paid on 19th of August 2019"),
                               (24,"Paid on 19th of August 2019"),
                               (25,"Paid on 19th of August 2019"),
                               (25,"Paid on 19th of August 2019"),
                               (23,"Paid on 19th of August 2019"),
                               (22,"Paid on 19th of August 2019"),
                               (21,"Paid on 19th of August 2019"),
                               (24,"Paid on 19th of August 2019"),
                               (24,"Paid on 19th of August 2019"),
                               (25,"Paid on 19th of August 2019"),
                               (25,"Paid on 19th of August 2019"),
                               (22,"Paid on 19th of August 2019"),
                               (21,"Paid on 19th of August 2019"),
                               (24,"Paid on 19th of August 2019"),
                               (24,"Paid on 19th of August 2019"),
                               (25,"Paid on 19th of August 2019"),
                               (25,"Paid on 19th of August 2019")]
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //tableView.isUserInteractionEnabled = false
        tblView.dataSource = self
        tblView.delegate = self
        tblView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "paymentCell")
        //self.tableView.rowHeight = 150
        
        // Set TableView height
        tblView.frame.size.height = cardHeight - handleImageView.frame.size.height
        
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! PaymentTableViewCell

        cell.amountPaidText.text = "£\(payments[indexPath.row].0)"
        cell.dateText.text = payments[indexPath.row].1
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableRowsHeight
    }
    
    
    
    
    
    //MARK: - Table Scroll Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //tableView.isUserInteractionEnabled = false
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        //tableView.isUserInteractionEnabled = false
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
    
    
    
    
    
    
}








//MARK: - Extension fro UIColor hex color representation
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

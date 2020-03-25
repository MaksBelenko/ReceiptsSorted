//
//  PaymentTableViewCell.swift
//  ReceiptsSorted
//
//  Created by Maksim on 26/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {
    
    var receivedPayment = true
    var tickColor = UIColor(rgb: 0x425C76)
    
    
    @IBOutlet weak var amountPaidText: UILabel!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var placeText: UILabel!
    @IBOutlet weak var tickLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.accessoryType = .disclosureIndicator
        
        tickLabel.layer.borderColor = tickColor.cgColor
        tickLabel.layer.borderWidth = 1
        tickLabel.layer.cornerRadius = tickLabel.frame.size.height/2
        tickLabel.layer.masksToBounds = true
        
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
    
    func setCell(for payment: Payments) {
        
        let p = payment
        
        self.amountPaidText.text = "£" + p.amountPaid.ToString(decimals: 2)
        self.placeText.text = p.place!
        self.dateText.text = "Paid on " + p.date!.ToString(as: .long) //parseDate(date: p.date!)
        self.receivedPayment = p.paymentReceived
        
        
        if (p.paymentReceived == true) {
            self.tickLabel.backgroundColor = tickColor.withAlphaComponent(1)
            self.tickLabel.text = "✓"
        } else {
            self.tickLabel.backgroundColor = tickColor.withAlphaComponent(0)
            self.tickLabel.text = ""
        }
    }
    
    
    
    func parseDate(date: Date) -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        return "Paid on \(day) of \(month) \(year)"
    }
}

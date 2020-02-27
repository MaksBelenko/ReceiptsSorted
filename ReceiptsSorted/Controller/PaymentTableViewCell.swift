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
    
    @IBOutlet weak var amountPaidText: UILabel!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var placeText: UILabel!
    @IBOutlet weak var tickLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.accessoryType = .disclosureIndicator
        
        tickLabel.layer.borderColor = UIColor.gray.cgColor
        tickLabel.layer.borderWidth = 1
        tickLabel.layer.cornerRadius = tickLabel.frame.size.height/2
        tickLabel.layer.masksToBounds = true
        
        if (receivedPayment == true) {
            tickLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(1)
            tickLabel.text = "✓"
        } else {
            tickLabel.backgroundColor = UIColor.green.withAlphaComponent(0)
            tickLabel.text = ""
        }
        
//        surroundView.backgroundColor = UIColor.white
//        surroundView.layer.borderColor = UIColor.black.cgColor
//        surroundView.layer.borderWidth = 0.2
//        surroundView.layer.cornerRadius = surroundView.frame.size.height/3
//        surroundView.layer.masksToBounds = true
//        
//        surroundView.layer.applyShadow()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

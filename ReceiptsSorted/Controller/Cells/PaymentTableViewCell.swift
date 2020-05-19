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
    
    @IBOutlet weak var tickLabelLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var amountPaidText: UILabel!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var placeText: UILabel!
    @IBOutlet weak var receivedLabel: UILabel!
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
    
    
    
    
    /**
     Configures cell
     - Parameter payment: Payment which data is used to populate cell
     - Parameter selectionEnabled: Shows weather tickbox should be shown
     */
    func setCell(for payment: Payments, selectionEnabled: Bool = false) {
        self.amountPaidText.text = "£" + payment.amountPaid.ToString(decimals: 2)
        self.placeText.text = payment.place!
        self.dateText.text = "Paid on " + payment.date!.ToString(as: .long) //parseDate(date: p.date!)
        self.receivedPayment = payment.paymentReceived
        
        receivedLabel.alpha = (payment.paymentReceived) ? 1 : 0
        
        if (selectionEnabled) {
            self.tickLabel.backgroundColor = tickColor.withAlphaComponent(0)
            self.tickLabel.text = ""
        }
        
        animateTick(show: selectionEnabled)
    }
    
    
    /**
     Changes the tickbox status
     - Parameter action: Used to show weather it should be ticked or empty
     */
    func selectCell(with action: SelectionAction) {
        switch action
        {
        case .Tick:
            tickLabel.backgroundColor = tickColor.withAlphaComponent(1)
            tickLabel.text = "✓"
        case .Untick:
            tickLabel.backgroundColor = tickColor.withAlphaComponent(0)
            tickLabel.text = ""
        }
    }
    
    
    
    
    // MARK: - Private methods
    
    private func animateTick(show: Bool) {
        tickLabelLeadingConstraint.isActive = false
        let constant: CGFloat = (show) ? 15 : -21
        tickLabelLeadingConstraint = tickLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: constant)
        tickLabelLeadingConstraint.isActive = true

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}

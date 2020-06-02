//
//  OnboardingText.swift
//  ReceiptsSorted
//
//  Created by Maksim on 02/06/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

struct OnboardingText {
    private let textHelper = TextHelper()
    
    lazy var segmentedControlText: NSMutableAttributedString = {
        let text = textHelper.setupLabel(inBold: "Pending",
                                         text: "tab shows payments paid by you but the company has not paid you back yet.")
        text.append(textHelper.setupLabel(inBold: "\n\nReceived",
                                          text: "tab shows the received from the company payments."))
        return text
    }()
    
    
    lazy var addReceiptsText: NSMutableAttributedString = {
        return textHelper.create(text: "Add new receipts by taking a photo or selecting from your photo library",
                                 bold: false, fontSize: 18)
    }()
    
    
    lazy var sendReceiptsText: NSMutableAttributedString = {
        return textHelper.create(text: """
        You can send your receipts as:
        • PDF
        • Zip Archive
        • or just images
        """, bold: false, fontSize: 18)
    }()
    
    lazy var indicatorsText: NSMutableAttributedString = {
        return textHelper.setupLabel(inBold: "Indicators",
                                     text: "for tracking how many receipts are still pending as well as deadline of sending all receipts")
    }()
}

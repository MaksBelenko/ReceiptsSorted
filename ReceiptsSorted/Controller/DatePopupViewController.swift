//
//  DatePopupViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 29/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit

class DatePopupViewController: UIViewController {

    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    
    var delegate: PopupDelegate?
    
    var formattedDate: String {
        get {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: datePicker.date)
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPopupLook()
    }


    func setupPopupLook() {
        popupView.layer.cornerRadius = 30
        selectButton.layer.cornerRadius = selectButton.frame.size.height/2
        topLabel.roundCorners(corners: [.topLeft, .topRight], radius: 30)
        
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        datePicker.setValue(false, forKeyPath: "highlightsToday")
    }
    

    
    @IBAction func selectDate(_ sender: UIButton) {
        delegate?.setDatepopupValue(value: formattedDate)
        dismiss(animated: true, completion: nil)
    }
    
}


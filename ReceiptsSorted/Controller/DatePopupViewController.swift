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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupView.layer.cornerRadius = 30
        selectButton.layer.cornerRadius = selectButton.frame.size.height/2
        topLabel.roundCorners(corners: [.topLeft, .topRight], radius: 30)
        
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        datePicker.setValue(false, forKeyPath: "highlightsToday")
    }



    @IBAction func selectDate(_ sender: UIButton) {
        dismiss(animated: true, completion: onSavePressed)
    }
    
    
    func onSavePressed() {
        
    }
}





//MARK: - Extensions

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

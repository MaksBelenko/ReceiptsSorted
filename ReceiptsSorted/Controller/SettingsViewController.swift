//
//  SettingsViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 25/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

protocol PickerProtocol: UIPickerViewDelegate, UIPickerViewDataSource {}

class SettingsViewController: UITableViewController {

    @IBOutlet var tblView: UITableView!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyArrowImage: UIImageView!
    @IBOutlet weak var receiptsRemovalPicker: UIPickerView!
    @IBOutlet weak var receiptRemovalArrowImage: UIImageView!
    
    private let settings = Settings.shared
    
    private let currencyPickerHelper = CurrencyPickerHelper()
    private let receiptRemovalPickerHelper = ReceiptRemovalPickerHelper()
    
    private enum SettingsTableRow {
        case Currency, CurrencyPicker
        case ImageCompression
        case ReceiptRemoval, ReceiptRemovalPicker
    }
    
    private let tableRow: [SettingsTableRow : IndexPath] = [ .Currency             : IndexPath(row: 0, section: 0),
                                                             .CurrencyPicker       : IndexPath(row: 1, section: 0),
                                                             .ImageCompression     : IndexPath(row: 2, section: 0),
                                                             .ReceiptRemoval       : IndexPath(row: 0, section: 1),
                                                             .ReceiptRemovalPicker : IndexPath(row: 1, section: 1)]
    
    // MARK: - Lifeycle
    override func viewDidLoad() {
        super.viewDidLoad()

        currencyLabel.text = settings.currencySymbol

        currencyPickerHelper.delegate = self
        setup(picker: currencyPicker, to: currencyPickerHelper)
        receiptRemovalPickerHelper.delegate = self
        setup(picker: receiptsRemovalPicker, to: receiptRemovalPickerHelper)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    


    // MARK: - TableView methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath
        {
        case tableRow[.Currency]:
            animate(picker: currencyPicker, arrow: currencyArrowImage) {
                let index = self.currencyPickerHelper.currencies.firstIndex(where: { $0.symbol == self.currencyLabel.text})!
                self.currencyPicker.selectRow(index, inComponent: 0, animated: false)
            }
        case tableRow[.ImageCompression]:
            Alert.shared.showImageCompressionInfo(for: self)
        case tableRow[.ReceiptRemoval]:
            animate(picker: receiptsRemovalPicker, arrow: receiptRemovalArrowImage, executeOnShow: nil)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath
        {
        case tableRow[.CurrencyPicker]:
            return currencyPicker.isHidden ? 0.0 : 216.0
        case tableRow[.ReceiptRemovalPicker]:
            return receiptsRemovalPicker.isHidden ? 0.0 : 130.0
        case tableRow[.ImageCompression]:
            return 97.0
        default:
            return 44
        }
    }
    
    // MARK: - Helpers
    
    /**
     Animate PickerView from hidden to unhidden and vice versa.
     - Parameter picker: PickerView that should be animated
     - Parameter arrow: Arrow of the picker view to be rotated on open and close
     - Parameter executeOnShow: If the next state is to show the PickerView execute the closure.
     */
    private func animate(picker: UIPickerView, arrow: UIImageView?, executeOnShow: (() -> ())? = nil) {
        picker.isHidden = !picker.isHidden
        UIView.animate(withDuration: 0.3) {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        if let image = arrow {
            let coeff: CGFloat = (picker.isHidden) ? 0 : 1
            UIView.animate(withDuration: 0.3) {
                image.transform = CGAffineTransform(rotationAngle: coeff * CGFloat.pi/2)
            }
        }
        if !picker.isHidden {
            executeOnShow?()
        }
    }
    
    /**
     Sets up PickerView's delegae and datasource to PickerHelper and sets PickerView
     to be hidden.
     - Parameter picker: Picker which delegate and dataSource should be mapped to helper
     - Parameter pickerHelper: Helper that will work with the delegate and dataSource
     */
    private func setup(picker: UIPickerView, to pickerHelper: PickerProtocol) {
           picker.isHidden = true
           picker.delegate = pickerHelper
           picker.dataSource = pickerHelper
       }
    

    
    // MARK: - @IBActions
    
    @IBAction func imageCompChanged(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
    }
    
}


// MARK: - CurrencyPickerDelegate
extension SettingsViewController: CurrencyPickerDelegate {
    func onCurrencySelected(symbol: String) {
        currencyLabel.text = symbol
        settings.currencySymbol = symbol
    }
}

// MARK: - ReceiptRemovalPickerDelegate
extension SettingsViewController: ReceiptRemovalPickerDelegate {
    func onRemoveOptionSelected(afterMonths monthsNumber: Int) {
        print("Selected option: \(monthsNumber) months")
    }
}

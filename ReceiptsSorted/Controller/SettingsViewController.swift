//
//  SettingsViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 25/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet var tblView: UITableView!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var receiptsRemovalPicker: UIPickerView!
    
    
    let settings = Settings.shared
    
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
        
        currencyPicker.isHidden = true
        currencyPickerHelper.delegate = self
        currencyPicker.delegate = currencyPickerHelper
        currencyPicker.dataSource = currencyPickerHelper
        
        receiptsRemovalPicker.isHidden = true
        receiptRemovalPickerHelper.delegate = self
        receiptsRemovalPicker.delegate = receiptRemovalPickerHelper
        receiptsRemovalPicker.dataSource = receiptRemovalPickerHelper
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    


    // MARK: - TableView methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath == tableRow[.Currency] {
            currencyPicker.isHidden = !currencyPicker.isHidden

            UIView.animate(withDuration: 0.3) {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
            
            let index = currencyPickerHelper.currencies.firstIndex(where: { $0.symbol == currencyLabel.text})!
            currencyPicker.selectRow(index, inComponent: 0, animated: false)
        }
        
        if indexPath == tableRow[.ReceiptRemoval] {
            receiptsRemovalPicker.isHidden = !receiptsRemovalPicker.isHidden

            UIView.animate(withDuration: 0.3) {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
            
//            let index = receiptRemovalPickerHelper.removeOptions.firstIndex(where: { $0.value == currencyLabel.text})!
//            currencyPicker.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath
        {
        case tableRow[.CurrencyPicker]:
            return currencyPicker.isHidden ? 0.0 : 216.0
        case tableRow[.ReceiptRemovalPicker]:
            return receiptsRemovalPicker.isHidden ? 0.0 : 100.0
        case tableRow[.ImageCompression]:
            return 97.0
        default:
            return 44
        }
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

extension SettingsViewController: ReceiptRemovalPickerDelegate {
    func onRemoveOptionSelected(afterMonths monthsNumber: Int) {
        print("Selected option: \(monthsNumber) months")
    }
}

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
    
    
    let settings = Settings.shared
    
    let currencies = WorldCurrencies().currencies //Locale.isoCurrencyCodes
    
    
    private enum SettingsTableRow {
        case Currency, CurrencyPicker
        case ImageCompression
    }
    
    private let tableRow: [SettingsTableRow : IndexPath] = [ .Currency           : IndexPath(row: 0, section: 0),
                                                             .CurrencyPicker     : IndexPath(row: 1, section: 0),
                                                             .ImageCompression   : IndexPath(row: 2, section: 0) ]
    
    // MARK: - Lifeycle
    override func viewDidLoad() {
        super.viewDidLoad()

        currencyLabel.text = settings.currencySymbol
        currencyPicker.isHidden = true
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    


    // MARK: - TableView methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        print(indexPath)
        if indexPath == tableRow[.Currency] {
            currencyPicker.isHidden = !currencyPicker.isHidden
            let alpha: CGFloat = (currencyPicker.isHidden) ? 1 : 1

            UIView.animate(withDuration: 0.3) {
                self.currencyPicker.alpha = alpha
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
            
            let index = currencies.firstIndex(where: { $0.symbol == currencyLabel.text})!
            currencyPicker.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath
        {
        case tableRow[.CurrencyPicker]:
            return currencyPicker.isHidden ? 0.0 : 216.0
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


// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let symbol = currencies[row].symbol
        currencyLabel.text = symbol
        settings.currencySymbol = symbol
    }
}

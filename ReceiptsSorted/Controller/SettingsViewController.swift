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
    
    @IBOutlet weak var dateIndicatorSC: UISegmentedControl!
    @IBOutlet weak var receiptsRemovalPicker: UIPickerView!
    @IBOutlet weak var receiptRemovalArrowImage: UIImageView!
    @IBOutlet weak var receiptRemovalLabel: UILabel!
    
    private let settings = SettingsUserDefaults.shared
    
    private let currencyPickerHelper = CurrencyPickerHelper()
    private let receiptRemovalPickerHelper = ReceiptRemovalPickerHelper()
    
    private enum SettingsTableRow {
        case Currency, CurrencyPicker
        case IndicatorTimePeriod
        case ReceiptRemoval, ReceiptRemovalPicker
        case ShowTutorial
    }
    
    private let tableRow: [SettingsTableRow : IndexPath] = [ .Currency             : IndexPath(row: 0, section: 0),
                                                             .CurrencyPicker       : IndexPath(row: 1, section: 0),
                                                             .IndicatorTimePeriod  : IndexPath(row: 2, section: 0),
                                                             .ReceiptRemoval       : IndexPath(row: 0, section: 1),
                                                             .ReceiptRemovalPicker : IndexPath(row: 1, section: 1),
                                                             .ShowTutorial         : IndexPath(row: 0, section: 2)]
    
    // MARK: - Lifeycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup pickers with helpers
        currencyPickerHelper.delegate = self
        setup(picker: currencyPicker, to: currencyPickerHelper)
        receiptRemovalPickerHelper.delegate = self
        setup(picker: receiptsRemovalPicker, to: receiptRemovalPickerHelper)
        
        // set from userdefaults
        currencyLabel.text = settings.getCurrency().symbol
        dateIndicatorSC.selectedSegmentIndex = SettingsUserDefaults.shared.getDateIndicatorPeriod().rawValue
        receiptRemovalLabel.text = getName(forMonths: settings.getReceiptRemovalPeriod())
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
            if currencyPicker.isHidden {
                Alert.shared.showCurrencyChangeWarning(for: self)
            }
            animate(picker: currencyPicker, arrow: currencyArrowImage) {
                let index = self.currencyPickerHelper.currencies.firstIndex(where: { $0.name == self.settings.getCurrency().name!})!
                self.currencyPicker.selectRow(index, inComponent: 0, animated: false)
            }
            
            
        case tableRow[.IndicatorTimePeriod]:
            Alert.shared.showDateIndicator(for: self)
            
            
        case tableRow[.ReceiptRemoval]:
            if receiptsRemovalPicker.isHidden {
                Alert.shared.showReceiptRemovalAlert(for: self)
            }
            animate(picker: receiptsRemovalPicker, arrow: receiptRemovalArrowImage) {
                let index = self.receiptRemovalPickerHelper.removeOptions.firstIndex(where: { $0.value == self.settings.getReceiptRemovalPeriod()})
                self.receiptsRemovalPicker.selectRow(index!, inComponent: 0, animated: false)
            }
            
            
        case tableRow[.ShowTutorial]:
            //sets userdefault for onboarding as "not shown"
            UserChecker().setIntroOnboardingAsShown(value: false)
            navigationController?.popViewController(animated: true)
            
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
            return receiptsRemovalPicker.isHidden ? 0.0 : 160.0
        case tableRow[.IndicatorTimePeriod]:
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
    
    @IBAction func timePeriodChanged(_ sender: UISegmentedControl) {
        let indicatorPeriod = sender.getIndicatorPeriod()
        settings.setIndicatorPeriod(to: indicatorPeriod)
    }
}


// MARK: - CurrencyPickerDelegate
extension SettingsViewController: CurrencyPickerDelegate {
    func onCurrencySelected(symbol: String, name: String) {
        currencyLabel.text = symbol
        settings.setDefaultCurrency(to: symbol, currencyName: name)
    }
    
}

// MARK: - ReceiptRemovalPickerDelegate
extension SettingsViewController: ReceiptRemovalPickerDelegate {
    func onRemoveOptionSelected(afterMonths monthsNumber: Int) {
        receiptRemovalLabel.text = getName(forMonths: monthsNumber)
        settings.setReceiptRemoval(after: monthsNumber)
    }
    
    
    // MARK: - Name helper
    func getName(forMonths number: Int) -> String {
        if number < 0 {
            return "Disable"
        }
        
        var removeText = "after \(number) "
        removeText += (number == 1) ? "month" : "months"
        return removeText
    }
}


//
//  SortingDropDownMenu.swift
//  ReceiptsSorted
//
//  Created by Maksim on 05/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class SortingDropDownMenu: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    
    private lazy var dropDownOptions: [String] = ["Place", "Date added (oldest)", "Date added (newest)"]
    
    let tableViewController = UITableViewController()
    private var button = UIButton()
    var sortButtonLabelDelegate: SortButtonLabelDelegate?
    
    
    
    
    
    
    /**
     Creates a popover with TableView
     - Parameter sender: A button which should activate drop down menu
     - Parameter size: Size of the drop down menu
     */
    func createDropDownMenu(for sender: UIButton, ofSize size: CGSize) -> UIPopoverPresentationController? {
        
        button = sender
        
        tableViewController.modalPresentationStyle = .popover
        tableViewController.preferredContentSize = size
        tableViewController.tableView.delegate = self
        tableViewController.tableView.dataSource = self
        
        // Used to make separators lines full width
        tableViewController.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //Removes uneeded separator lines at the end of TableView
        tableViewController.tableView.tableFooterView = UIView()
        
        tableViewController.tableView.showsVerticalScrollIndicator = false
//        tableViewController.tableView.isScrollEnabled = false
//        tableViewController.tableView.contentInset = UIEdgeInsets(top: tableViewController.tableView.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
          
        let popoverPresentationController = tableViewController.popoverPresentationController
        popoverPresentationController?.sourceView = sender
        popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: sender.frame.size.width, height: sender.frame.size.height)
        
        popoverPresentationController?.permittedArrowDirections = .up
        
        return popoverPresentationController
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.frame.size.height = 30
        cell.textLabel?.text = dropDownOptions[indexPath.row]
        cell.textLabel?.textAlignment = .right
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(dropDownOptions[indexPath.row])")
        
        sortButtonLabelDelegate?.changeButtonLabel(sortByOption: getSortType(for: dropDownOptions[indexPath.row]))
        
        tableViewController.dismiss(animated: true, completion: nil)
    }
    
    
    
    func getSortType(for name: String) -> SortBy {
        var sortOption: SortBy?
        
        switch name {
            case "Place":
                sortOption = .Place
            case "Date added (oldest)":
                sortOption = .OldestDateAdded
            case "Date added (newest)":
                sortOption = .NewestDateAdded
            default:
                print("Error retrieving name in popover")
                break
        }
        
        
        return sortOption!
    }
    
}

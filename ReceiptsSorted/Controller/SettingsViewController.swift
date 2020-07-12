//
//  SettingsViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 25/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    

}

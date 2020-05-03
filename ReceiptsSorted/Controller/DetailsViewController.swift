//
//  DetailsViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 02/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    override func viewWillLayoutSubviews() {
       
    }
    
    
    
    override func viewDidLoad() {
       super.viewDidLoad()
        
        view.backgroundColor = .red
        
        let navigationBar: UINavigationBar = UINavigationBar()
        self.view.addSubview(navigationBar);
        
        navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        let navigationItem = UINavigationItem(title: "Navigation bar")
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(selectorX))
        navigationItem.rightBarButtonItem = doneBtn
        navigationBar.setItems([navigationItem], animated: false)
    }
    
    
    
    @objc func selectorX() { }

}

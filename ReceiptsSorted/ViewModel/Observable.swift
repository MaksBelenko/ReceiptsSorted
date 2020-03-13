//
//  Observable.swift
//  ReceiptsSorted
//
//  Created by Maksim on 13/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

class Observable<T> {
    
    var value: T {
        didSet {
            DispatchQueue.main.async {
                self.valueChanged?(self.value)
            }
        }
    }
    
    var valueChanged: ((T) -> Void)?
    
    init(_ v: T) {
      value = v
    }
}

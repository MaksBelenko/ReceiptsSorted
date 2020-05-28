//
//  Observable.swift
//  ReceiptsSorted
//
//  Created by Maksim on 13/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

final class Observable<T> {
    
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}


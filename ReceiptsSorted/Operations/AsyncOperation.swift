//
//  AsyncOperation.swift
//  ReceiptsSorted
//
//  Created by Maksim on 07/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    
    // MARK: - State management
    enum State: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String {
            return "is\(rawValue.capitalized)"
        }
    }
    
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    // MARK: - Override properties
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    
    
    // MARK: - Override start
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        
        main()
        state = .executing
    }
}


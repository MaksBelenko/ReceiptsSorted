//
//  IndicatorAnimation.swift
//  ReceiptsSorted
//
//  Created by Maksim on 08/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class IndicatorAnimation<T: CALayer> {
    
    typealias ProgressHandler = (Double) -> ()
    
    private let indicator: T
    private let animationDuration: CFTimeInterval
    private var animationStartTime = Date()
    
    private var progressHandler: ProgressHandler!
    private var progressCompletion: (() -> ())!
    
    
    init(indicator: T, duration animationDuration: CFTimeInterval) {
        self.indicator = indicator
        self.animationDuration = animationDuration
    }
    
    
    @discardableResult
    func executeIndicatorAnimation(for keyPath: String, fromValue: Any?, toValue: Any?) -> String {
        let animation = CABasicAnimation(keyPath: keyPath)  //#keyPath(CAShapeLayer.strokeEnd))
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = animationDuration
        /* Keep animation after completion */
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        // animation curve is Ease Out
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        let animationKey = "animation_\(keyPath)_\(UUID())"
        indicator.add(animation, forKey: animationKey)
        
        return animationKey
    }
    
    
    
    
    /**
     Cretas CADisplayLink for the label (UILabel should be binded to overallAmount)
     */
    func createDisplayLink(progressHandler: @escaping ProgressHandler, completion: @escaping () -> () ) {
        animationStartTime = Date() // set start time
        
        self.progressHandler = progressHandler
        self.progressCompletion = completion
        
        let displaylink = CADisplayLink(target: self, selector: #selector(step))
        displaylink.add(to: .current, forMode: .default)
    }
    
    
         
    /**
     Handles updates for the label
     - Parameter displaylink: Used to remove the link when the animation has finished
     */
    @objc private func step(displaylink: CADisplayLink) {
        
        let currentAnimationTime = Date()
        let elapsedTime = currentAnimationTime.timeIntervalSince(animationStartTime)
        
        if (elapsedTime < animationDuration) {
            let percentageComplete = elapsedTime / animationDuration
            progressHandler(percentageComplete)
        } else {
            progressHandler(1)
            progressCompletion()
            displaylink.remove(from: .current, forMode: .default)
        }
        
    }
    
    
}

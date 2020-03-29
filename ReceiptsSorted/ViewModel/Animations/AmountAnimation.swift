//
//  AmountAnimation.swift
//  ReceiptsSorted
//
//  Created by Maksim on 25/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class AmountAnimation {
    
    ///Bind to UILabel
    var overallAmount: Observable<Float> = Observable(0.0)
    
    private var animationDuration: Double = 0.7
    private var animationCircle: CAShapeLayer!
    private var startValue: Float = 0
    private var endValue: Float = 100
    private var animationStartTime = Date()
    
    
    
    
    init(animationCircle: CAShapeLayer) {
        self.animationCircle = animationCircle
    }
    
    
    
    /**
     Animates circle graphics as well as UILabel binded to overallAmount
     - Parameter startValue: Value from which the animation should start (in £)
     - Parameter endValue: Value at which animation should end (in £)
     */
    func animateCircle(from startValue: Float = 0, to endValue: Float ) {
        animationStartTime = Date()
        overallAmount.value = startValue
        self.startValue = startValue
        self.endValue = endValue
        
        
        createCircleAnimation()
        createDisplayLink()
    }
    
    
    /**
     Creates animation for the circle graphics
     */
    func createCircleAnimation() {
        let circleAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circleAnimation.fromValue = overallAmount.value/1000
        circleAnimation.toValue = self.endValue/1000
        circleAnimation.duration = animationDuration
        /* Keep animation after completion */
        circleAnimation.fillMode = .forwards
        circleAnimation.isRemovedOnCompletion = false
        animationCircle.add(circleAnimation, forKey: "circleAnim")
    }
    
    
    
    
    /**
     Cretas CADisplayLink for the label (UILabel should be binded to overallAmount)
     */
    private func createDisplayLink() {
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
        
        if (elapsedTime <= animationDuration) {
            let percentageComplete = elapsedTime / animationDuration
            let value = startValue + Float(percentageComplete) * (endValue - overallAmount.value)
            overallAmount.value = value
        } else {
            overallAmount.value = endValue
            displaylink.remove(from: .current, forMode: .default)
        }
        
    }
}

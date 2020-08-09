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
    
    /// Maximum value that indicates the full circle
    var maxValue: Float = 1000
    
    private var animationDuration: Double = 0.7
    private var animationCircle: CAShapeLayer!
    private var trackStartValue: Float = 0.0
    
    
    
    init(animationCircle: CAShapeLayer) {
        self.animationCircle = animationCircle
    }
    
    
    
    /**
     Animates circle graphics as well as UILabel binded to overallAmount
     - Parameter sValue: Value from which the animation should start
     - Parameter endValue: Value at which animation should end
     */
    func animateCircle(from sValue: Float? = nil , to endValue: Float) {
        let startValue = (sValue == nil) ? trackStartValue : sValue!
        
        overallAmount.value = startValue //before animation executed
        trackStartValue = endValue
        
        if (withinZeroBounds(for: endValue) == false) {
            animationCircle.opacity = 1.0
        }
        
        
        let indicatorAnimation = IndicatorAnimation(indicator: animationCircle, duration: animationDuration)
        
        indicatorAnimation.executeIndicatorAnimation(for: #keyPath(CAShapeLayer.strokeEnd),
                                                     fromValue: startValue / maxValue,
                                                     toValue: endValue / maxValue)
        
        
        indicatorAnimation.createDisplayLink(progressHandler: { [unowned self] progress in
            let value = startValue + Float(progress) * (endValue - startValue)
            self.overallAmount.value = value
        }) { [unowned self] in
            self.animationCircle.opacity = (self.withinZeroBounds(for: endValue)) ? 0.0 : 1.0
        }
    }
    
    
    private func withinZeroBounds(for value: Float) -> Bool {
        return (value < 0.001 && value > -0.001)
    }
    
    
    
}

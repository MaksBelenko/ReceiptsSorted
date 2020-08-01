//
//  DateAnimation.swift
//  ReceiptsSorted
//
//  Created by Maksim on 31/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class DateAnimation {
    
    
    private let dateIndicator: CALayer
    var overallDays: Observable<Float> = Observable(0.0)
    
    /// Maximum number of days (eg 7 30, 31) for the period
    var maxDays: Float = 7
    private var currentDay: Float = 5
    private var animationDuration: Double = 10//0.7
    
    
    
    
    init(dateIndicator: CALayer) {
        self.dateIndicator = dateIndicator
    }
    

    
    /**
     Animates date indicator
     - Parameter startValue:
     - Parameter endValue:
     */
    func animateDate(from startValue: Float = -1 , to endValue: Float ) {
//        let beginValue = (startValue == -1) ? trackStartValue : startValue
        
//        overallAmount.value = beginValue //before animation executed
//        self.startValue = beginValue
        self.currentDay = endValue
//        trackStartValue = endValue
        
        if endValue != 0.0 {
            dateIndicator.opacity = 1.0
        }
        
        createDateAnimation()
    }
    

    /**
     Creates animation for the circle graphics
     */
    func createDateAnimation() {
        let dateAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        dateAnimation.fromValue = overallDays.value/maxDays
        dateAnimation.toValue = 1//self.currentDay/maxDays
        dateAnimation.duration = animationDuration
        /* Keep animation after completion */
        dateAnimation.fillMode = .forwards
        dateAnimation.isRemovedOnCompletion = false
        dateIndicator.add(dateAnimation, forKey: "dateAnimation")
    }
    
}

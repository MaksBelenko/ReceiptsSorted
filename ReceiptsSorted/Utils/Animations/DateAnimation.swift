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
    private var animationDuration: Double = 0.7
    
    private var startDay: Float = 0
    private var trackStartValue: Float = 0.0
    
    private let maxLength: CGFloat
    
    
    
    init(dateIndicator: CALayer) {
        self.dateIndicator = dateIndicator
        self.maxLength = dateIndicator.bounds.width
    }
    

    
    /**
     Animates date indicator
     - Parameter startValue:
     - Parameter endValue:
     */
    func animateDate(from startValue: Float = -1 , to endValue: Float ) {
        let beginValue = (startValue == -1) ? trackStartValue : startValue
        
//        overallAmount.value = beginValue //before animation executed
        self.startDay = beginValue
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
        let dateAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.bounds))
        
        var startBounds = dateIndicator.bounds //dateIndicator.presentation()?.bounds
        startBounds.size.width = CGFloat(startDay/maxDays) * maxLength
        dateAnimation.fromValue = startBounds
        
        var endBounds = dateIndicator.bounds
        endBounds.size.width = CGFloat(currentDay/maxDays) * maxLength
        dateAnimation.toValue = endBounds
        
        
        dateAnimation.duration = animationDuration
        /* Keep animation after completion */
        dateAnimation.fillMode = .forwards
        dateAnimation.isRemovedOnCompletion = false
        // animation curve is Ease Out
        dateAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        dateIndicator.add(dateAnimation, forKey: "dateAnimation")
    }
    
}

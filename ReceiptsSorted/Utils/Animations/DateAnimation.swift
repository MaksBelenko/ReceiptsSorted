//
//  DateAnimation.swift
//  ReceiptsSorted
//
//  Created by Maksim on 31/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class DateAnimation {
    
    // MARK: - Public properties
    
    /// Observer for the days that are currently showing
    var daysLeft: Observable<Int> = Observable(0)
    /// Maximum number of days (eg 7, 30, 31) for the period
    var maxDays: Int = 0
    
    
    
    // MARK: - Private properties
    
    private var dateHelper: DateHelper!
    
    private let dateIndicator: CALayer
    private var animationDuration: Double = 0.7
    private var currentDay: Int = 5
    private var startDay: Float = 0
    private let maxLength: CGFloat
    private var animationStartTime = Date()
    private var overallDays: Float = 0.0 {
        didSet {
            daysLeft.value = maxDays - Int(overallDays)
        }
    }
    
//    private let settings = SettingsUserDefaults.shared
    
    
    // MARK: - Initialisation
    
    init(dateIndicator: CALayer) {
        self.dateIndicator = dateIndicator
        self.maxLength = dateIndicator.bounds.width
        initialiseDateHelper()
    }
    

    // MARK: - Bindings
    
    /**
     Initialises DatHelper with the closure to listen for day changes notifications
     */
    private func initialiseDateHelper() {
        dateHelper = DateHelper(onDayChanged: { [unowned self] currentDay in
            self.animateDate(to: currentDay)
//            self.switchToNextDay()
        })
    }
     
    
//    private func switchToNextDay() {
//        let animateTo = (currentDay % maxDays) + 1
//        self.animateDate(to: animateTo)
//    }
    
    
    // MARK: - Animation methods
    
    /**
     Animates the date indicator from 0 to current day in a month
     */
    func animateToCurrentDate() {
        maxDays = dateHelper.daysInCurrentMonth
        animateDate(to: dateHelper.currentDay)
    }
    
    
    /**
     Animates date indicator
     - Parameter startValue: From what date to be animated from
     - Parameter endValue: to what day it should be animated
     */
    private func animateDate(from startValue: Float = -1 , to endValue: Int) {
        let beginValue = (startValue == -1) ? Float(currentDay) : startValue
        
        animationStartTime = Date()
        self.overallDays = beginValue //before animation executed
        self.startDay = beginValue
        
        self.currentDay = endValue
        
        if endValue != 0 {
            dateIndicator.opacity = 1.0
        }
        
        createDateAnimation()
        createDisplayLink()
    }
    

    /**
     Creates animation for the circle graphics
     */
    func createDateAnimation() {
        let dateAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.bounds))
        dateAnimation.fromValue = getBounds(for: startDay)
        dateAnimation.toValue = getBounds(for: Float(currentDay))
        dateAnimation.duration = animationDuration
        /* Keep animation after completion */
        dateAnimation.fillMode = .forwards
        dateAnimation.isRemovedOnCompletion = false
        // animation curve is Ease Out
        dateAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        dateIndicator.add(dateAnimation, forKey: "dateAnimation")
    }
    
    
    
    /**
     Creates CADisplayLink for the label (UILabel should be binded to overallAmount)
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
            let value = startDay + Float(percentageComplete) * (Float(currentDay) - startDay)
            overallDays = value
        } else {
            overallDays = Float(currentDay)
            dateIndicator.opacity = (currentDay == 0) ? 0.0 : 1.0
            displaylink.remove(from: .current, forMode: .default)
        }
        
    }
    
    
    
    // MARK: - Helpers
    
    private func getBounds(for day: Float) -> CGRect {
        var bounds = dateIndicator.bounds //dateIndicator.presentation()?.bounds
        bounds.size.width = CGFloat(day/Float(maxDays)) * maxLength
        return bounds
    }
    
}

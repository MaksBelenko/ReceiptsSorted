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
    var maxDays: Float = 0
    
    
    
    // MARK: - Private properties
    
    private var dateHelper: DateHelper!
    
    private let dateIndicator: CALayer
    private var animationDuration: Double = 0.7
    private var currentDay: Float = 5
    private var startDay: Float = 0
    private var trackStartValue: Float = 0.0
    private let maxLength: CGFloat
    private var animationStartTime = Date()
    private var overallDays: Float = 0.0 {
        didSet {
            daysLeft.value = Int(maxDays - overallDays)
//            if (Int(overallDays) != observedDays.value) {
//                observedDays.value = Int(overallDays)
//            }
        }
    }
    
    
    
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
        dateHelper = DateHelper(onDayChanged: { [unowned self] newDay in
            let currentDay = Float(newDay)
            self.animateDate(to: currentDay)
        })
    }
    
    // MARK: - Animation methods
    
    /**
     Animates the date indicator from 0 to current day in a month
     */
    func animateToCurrentDate() {
        let daysInMonth = Float(dateHelper.daysInCurrentMonth)
        let currentDay = Float(dateHelper.currentDay)
        maxDays = daysInMonth
        animateDate(to: currentDay)
    }
    
    
    /**
     Animates date indicator
     - Parameter startValue: From what date to be animated from
     - Parameter endValue: to what day it should be animated
     */
    private func animateDate(from startValue: Float = -1 , to endValue: Float ) {
        let beginValue = (startValue == -1) ? trackStartValue : startValue
        
        animationStartTime = Date()
        self.overallDays = beginValue //before animation executed
        self.startDay = beginValue
        self.currentDay = endValue
        trackStartValue = endValue
        
        if endValue != 0.0 {
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
        dateAnimation.toValue = getBounds(for: currentDay)
        dateAnimation.duration = animationDuration
        /* Keep animation after completion */
        dateAnimation.fillMode = .forwards
        dateAnimation.isRemovedOnCompletion = false
        // animation curve is Ease Out
        dateAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        dateIndicator.add(dateAnimation, forKey: "dateAnimation")
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
            let value = startDay + Float(percentageComplete) * (currentDay - startDay)
            overallDays = value
        } else {
            overallDays = currentDay
            dateIndicator.opacity = (currentDay == 0) ? 0.0 : 1.0
            displaylink.remove(from: .current, forMode: .default)
        }
        
    }
    
    
    
    // MARK: - Helpers
    
    private func getBounds(for day: Float) -> CGRect {
        var bounds = dateIndicator.bounds //dateIndicator.presentation()?.bounds
        bounds.size.width = CGFloat(day/maxDays) * maxLength
        return bounds
    }
    
}

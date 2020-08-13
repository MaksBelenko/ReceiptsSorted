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
    private var currentDay: Int = 0
    private let maxLength: CGFloat
    private var animationStartTime = Date()
    private var overallDays: Int = 0 {
        didSet {
            daysLeft.value = maxDays - Int(overallDays)
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
        dateHelper = DateHelper(onDayChanged: { [unowned self] (currentDay, daysInPeriod) in
            self.maxDays = daysInPeriod
            self.animateDate(to: currentDay)
        })
    }
     
    
    
    // MARK: - Animation methods
    
    /**
     Animates the date indicator from 0 to current day in a month
     */
    func animateToCurrentDate() {
        maxDays = dateHelper.daysInCurrentPeriod
        animateDate(to: dateHelper.currentDay)
    }
    
    
    /**
     Animates date indicator
     - Parameter sValue: From what date to be animated from
     - Parameter endValue: to what day it should be animated
     */
    private func animateDate(from sValue: Int? = nil , to endValue: Int) {
        let startValue = (sValue == nil) ? currentDay : sValue!
        
        animationStartTime = Date()
        self.overallDays = startValue //before animation executed
        self.currentDay = endValue
        
        if endValue != 0 {
            dateIndicator.opacity = 1.0
        }
        
        
        let indicatorAnimation = IndicatorAnimation(indicator: dateIndicator, duration: animationDuration)
        
        indicatorAnimation.executeIndicatorAnimation(for: #keyPath(CALayer.bounds),
                                                     fromValue: getBounds(for: startValue),
                                                     toValue:   getBounds(for: endValue))
        
        indicatorAnimation.createDisplayLink(progressHandler: { [unowned self] progress in
            let value = startValue + Int(progress * Double(endValue - startValue))
            self.overallDays = value
        }) { [unowned self] in
            self.dateIndicator.opacity = (endValue == 0) ? 0.0 : 1.0
        }
        
    }
    

    
    
    
    // MARK: - Helpers
    
    private func getBounds(for day: Int) -> CGRect {
        var bounds = dateIndicator.bounds //dateIndicator.presentation()?.bounds
        bounds.size.width = CGFloat(day)/CGFloat(maxDays) * maxLength
        return bounds
    }
    
}

//
//  NitificationScheduler.swift
//  ReceiptsSorted
//
//  Created by Maksim on 13/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import UserNotifications

class PushNotificationScheduler {
    
    private let center = UNUserNotificationCenter.current()
    private let settings = SettingsUserDefaults.shared
    private var notificationIdentifiers: [String] = []
    
    private var accessGranted = false
    
    
    // MARK: - Lifecycle
    init() {
        settings.addDateChangedListener(self)
    }
    
    
    
    
    
    
    /**
     Request authorization
     */
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert,.sound,.badge]) { [weak self] (granted, error) in
            print("Push notifications access Granted? \(granted)")
            self?.accessGranted = granted
            
            if let error = error {
                Log.exception(message: "Error requesting authorization for Push notification: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    /**
     Schedules the notification with the passed request
     - Parameter request: Request that should be scheduled
     - Returns: Request identifier
     */
    @discardableResult
    func scheduleNotification(with request: UNNotificationRequest) -> String {
        
        center.add(request) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                Log.exception(message: "Failed to schedule notification. \(error.localizedDescription)")
            }
        }
        
        notificationIdentifiers.append(request.identifier)
        return request.identifier
    }
    
    /**
     Remove all notifications
     */
    func removeAllNotifications() {
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        notificationIdentifiers.removeAll()
    }
    
    /**
     Removes notifications which have the passed identifier
     - Parameter identifier: Request identifier
     */
    func removeNotifications(with identifier: String) {
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        notificationIdentifiers = notificationIdentifiers.filter { $0 != identifier }
    }
}

// MARK: - DateSettingChangedProtocol
extension PushNotificationScheduler: DateSettingChangedProtocol {
    
    func dateIndicatorSettingChanged(to period: IndicatorPeriod) {
        print("Changed in PushNotificationScheduler to \(period)")
        
        removeAllNotifications()
        
//        schedule()
//
//        center.getPendingNotificationRequests { [weak self] requests in
//            let r = requests
//        }
//
//        center.getDeliveredNotifications { [weak self] requests in
//            let r = requests
//        }
    }
    
    private func schedule() {
        let endOfMonthDate = Date().endOfMonth()
        let components = Calendar.current.dateComponents([.year, .month, .day], from: endOfMonthDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = PushNotificationRequestBuilder()
                                .withTrigger(trigger)
                                .withTitle("Test Title")
                                .withBody("Test long body")
                                .withSoundEnabled(true)
                                .withBadge(1)
                                .build()
        
        scheduleNotification(with: request)
    
    }
    
}




extension Date {
    func startOfMonth() -> Date? {
        let components: DateComponents = Calendar.current.dateComponents([.year, .month, .hour],
                                                                         from: Calendar.current.startOfDay(for: self))
        return Calendar.current.date(from: components)!
    }

    func endOfMonth() -> Date {
        var components = Calendar.current.dateComponents([.month, .day, .hour],
                                                         from: Calendar.current.startOfDay(for: self))
        components.month = 1
        components.day = -1
        return Calendar.current.date(byAdding: components, to: self.startOfMonth()!)!
    }
}



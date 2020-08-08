//
//  NitificationScheduler.swift
//  ReceiptsSorted
//
//  Created by Maksim on 13/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import UserNotifications

class PushNotificationScheduler: NSObject {
    
    private let center = UNUserNotificationCenter.current()
    private let settings = SettingsUserDefaults.shared
    private var notificationIdentifiers: [String] = []
    
    private var accessGranted = false
    
    
    // MARK: - Triggers
    
    private var endOfMonthTrigger: UNCalendarNotificationTrigger = {
        let endOfMonthDate = Date().endOfMonth()
        var components = Calendar.current.dateComponents([.day], from: endOfMonthDate)
        components.hour = 11
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    }()
    
    
    private var fridayWeekTrigger: UNCalendarNotificationTrigger = {
        var components = DateComponents()
        components.weekday = 6 // Friday
        components.hour = 11
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    }()
    
    
    private var testTrigger: UNNotificationTrigger = {
        var components = DateComponents()
        components.second = 30
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
//        return UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
    }()
    
    
    
    
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        settings.addDateChangedListener(self)
    }
    
    
    // MARK: - Authorisation and appearance
    /**
     Request authorization
     */
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert,.sound,.badge]) { [weak self] (granted, error) in
            print("Push notifications access Granted? \(granted)")
            
            guard let self = self else { return }
            self.accessGranted = granted
            
            if granted {
                self.center.delegate = self
            }
            
            if let error = error {
                Log.exception(message: "Error requesting authorization for Push notification: \(error.localizedDescription)")
            }
        }
    }
    
    
    /**
    Remove push notification icon badge
     */
    func removeIconBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
    
    // MARK: - Scheduling
    
    /**
    Schedules the notification for the time period
    - Parameter period: Current time period
    - Returns: Request identifier
    */
    func schedule(for period: IndicatorPeriod) -> String {
        let trigger = (period == .Week) ? fridayWeekTrigger : endOfMonthTrigger
         
        let request = PushNotificationRequestBuilder()
                                .withTrigger(trigger)
                                .withTitle("Reminder:")
                                .withBody("Don't forget to send back your receipts! 🧾")
                                .withSoundEnabled(true)
                                .withBadge(1)
                                .build()
        
        scheduleNotification(with: request)
        
        return request.identifier
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
    
    
    // MARK: - Removing push notifications
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
    
    
    // MARK: - Notification tracking
    
    
}

// MARK: - DateSettingChangedProtocol
extension PushNotificationScheduler: DateSettingChangedProtocol {
    
    func dateIndicatorSettingChanged(to period: IndicatorPeriod) {
        print("Changed in PushNotificationScheduler to \(period)")
        
        removeAllNotifications()
        
        schedule(for: period)

        center.getPendingNotificationRequests { [weak self] requests in
            let r = requests
        }

        center.getDeliveredNotifications { [weak self] requests in
            let r = requests
        }
    }
    
}

// MARK: - UNUserNotificationCenterDelegate
extension PushNotificationScheduler: UNUserNotificationCenterDelegate {
    
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

//    refreshNotificationList()

    completionHandler([.alert, .sound, .badge])
  }
}



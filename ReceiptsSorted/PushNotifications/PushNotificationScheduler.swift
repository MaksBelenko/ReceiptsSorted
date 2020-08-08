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
    
    
    private var endOfMonthTrigger: UNCalendarNotificationTrigger = {
        let endOfMonthDate = Date().endOfMonth()
        let components = Calendar.current.dateComponents([.year, .month, .day], from: endOfMonthDate)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
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
        
        schedule()

        center.getPendingNotificationRequests { [weak self] requests in
            let r = requests
        }

        center.getDeliveredNotifications { [weak self] requests in
            let r = requests
        }
    }
    
    private func schedule() {
        let request = PushNotificationRequestBuilder()
                                .withTrigger(testTrigger)
                                .withTitle("Reminder:")
                                .withBody("Don't forget to send back your receipts! 🧾")
                                .withSoundEnabled(true)
                                .withBadge(1)
                                .build()
        
        scheduleNotification(with: request)
    
    }
    
}


extension PushNotificationScheduler: UNUserNotificationCenterDelegate {
    
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

//    refreshNotificationList()

    completionHandler([.alert, .sound, .badge])
  }
}



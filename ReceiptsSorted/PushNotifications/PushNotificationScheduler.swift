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
    
    let center = UNUserNotificationCenter.current()
    
    
    /**
     Schedules the notification with the passed request
     - Parameter request: Request that should be scheduled
     - Returns: Request identifier
     */
    func scheduleNotification(request: UNNotificationRequest) -> String {
        
        center.add(request) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                Log.exception(message: "Failed to schedule notification. \(error.localizedDescription)")
            }
        }
        
        return request.identifier
    }
}



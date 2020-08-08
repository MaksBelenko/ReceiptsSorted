//
//  PushNotificationRequestBuilder.swift
//  ReceiptsSorted
//
//  Created by Maksim on 13/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import UserNotifications


class PushNotificationRequestBuilder {
    
    let identifier = UUID().uuidString
    private let content = UNMutableNotificationContent()
    private var trigger: UNNotificationTrigger?
    
    
    func withTrigger(_ trigger: UNNotificationTrigger?) -> PushNotificationRequestBuilder {
        self.trigger = trigger
        return self
    }
    
    @discardableResult
    func withTitle(_ title: String) -> PushNotificationRequestBuilder {
        content.title = title
        return self
    }
    
    @discardableResult
    func withBody(_ body: String) -> PushNotificationRequestBuilder {
        content.body = body
        return self
    }
    
    
    @discardableResult
    func withSoundEnabled(_ soundEnabled: Bool) -> PushNotificationRequestBuilder {
        content.sound = UNNotificationSound.default
        return self
    }
    
    @discardableResult
    func withBadge(_ number: Int) -> PushNotificationRequestBuilder {
        content.badge = NSNumber(value: number)
        return self
    }
    
    
    func build() -> UNNotificationRequest {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        return request
    }
}

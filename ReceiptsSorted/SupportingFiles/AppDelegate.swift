//
//  AppDelegate.swift
//  ReceiptsSorted
//
//  Created by Maksim on 16/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import CoreData


//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var coreDataStack: CoreDataStack!
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      return true
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setStateForUITestingIfNeeded()
        
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    
    // MARK: - Setup for UI tests
    static var isUITestingEnabled: Bool {
        get {
            return ProcessInfo.processInfo.arguments.contains("IS_RUNNING_UITEST")
        }
    }
    
    private func setStateForUITestingIfNeeded() {
        if AppDelegate.isUITestingEnabled {
            FileManager.default.cleanDatabaseFilesForTests()
        }
        
        coreDataStack = CoreDataStack()
    }
}


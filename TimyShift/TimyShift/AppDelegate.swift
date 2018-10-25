//
//  AppDelegate.swift
//  TimyShift
//
//  Created by USER on 2018/8/31.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

var db: Firestore!
//let userId = UserManager.um[keyPath: \UserManager.userId]
//let currentGroupId = UserManager.um[keyPath: \UserManager.groupIds[UserManager.um.groupIndex]]
//let currentGroup = GroupManager.gm[keyPath: \GroupManager.groups[currentGroupId]]
//let currentUser = GroupManager.gm[keyPath: \GroupManager.groups[currentGroupId]?.members[userId]]


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // [START setup]
        FirebaseApp.configure()
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        // [END setup]
        
        if !application.isRegisteredForRemoteNotifications {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotifications()
        }
        
        //讀檔並決定要進入哪一個畫面
        if DataManager.dm.loadLocalData() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MainController")
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}


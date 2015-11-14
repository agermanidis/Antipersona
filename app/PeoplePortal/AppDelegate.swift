//
//  AppDelegate.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/8/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

typealias Dict = Dictionary<String, AnyObject>

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        application.registerUserNotificationSettings(UIUserNotificationSettings (forTypes: UIUserNotificationType.Alert, categories: nil))
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(
            UIApplicationBackgroundFetchIntervalMinimum)

        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var viewControllerName: String
        
        switch Session.shared.userProgress {
        case .Initial:
            viewControllerName = "InitialView"
        case .Selection:
            viewControllerName = "SelectionView"
        case .Shadowing:
            viewControllerName = "MainView"
        }
        
        let vc = storyboard.instantiateViewControllerWithIdentifier(viewControllerName)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        Session.shared.shadowedUser?.stop()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        

    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Session.shared.shadowedUser?.start()

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Session.shared.shadowedUser?.stop()
        Session.shared.save()
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        let vc = self.window?.rootViewController as! MainViewController
        vc.selectedIndex = 1

    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        completionHandler(.NewData)
        if Session.shared.shadowedUser != nil {
            let shadowedUser = Session.shared.shadowedUser!
            shadowedUser.waitForWorkers([MentionsWorker.self]) {
                
            }
        }
    }

}


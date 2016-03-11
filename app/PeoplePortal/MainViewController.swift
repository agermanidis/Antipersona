//
//  MainViewController.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/25/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import Async

class MainViewController: UITabBarController, UITabBarControllerDelegate {
    var timelineVC: TimelineViewController?
    var notificationsVC: NotificationsViewController?
    var profileVC: ProfileViewController?
    
    var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        Session.shared.shadowedUser?.onNotificationsChanged({
            self.updateBadge()
        })
        self.updateBadge()

        timelineVC = (viewControllers![0] as! UINavigationController).visibleViewController as? TimelineViewController
        notificationsVC = (viewControllers![1] as! UINavigationController).visibleViewController as? NotificationsViewController
        profileVC = (viewControllers![2] as! UINavigationController).visibleViewController as? ProfileViewController
        
        currentViewController = profileVC
        
        // Do any additional setup after loading the view.
    }
    
    func updateBadge() {
        Async.main {
            let n = Session.shared.shadowedUser!.numberOfUnseenNotifications
            self.viewControllers![1].tabBarItem.badgeValue = Utils.badgeText(n)
            UIApplication.sharedApplication().applicationIconBadgeNumber = n
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let rootVC = (viewController as! UINavigationController).visibleViewController

        if currentViewController == rootVC {
            if currentViewController == timelineVC {
                print("timelineVC")
                timelineVC?.scrollToTop()
            } else if currentViewController == notificationsVC {
                print("notVC")
                notificationsVC?.scrollToTop()
            } else {
                print("profVC")
                profileVC?.scrollToTop()
            }
        }
        
        currentViewController = rootVC
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

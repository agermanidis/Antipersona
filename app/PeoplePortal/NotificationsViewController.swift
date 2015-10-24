//
//  NotificationsViewController.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/23/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import Async

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var footerMessage: String {
        get {
            if notifications.count > 0 {
                return ""
            } else {
                return "No notifications to display"
            }
        }
    }
    
    var notifications: [Notification] {
        get {
            return Session.shared.shadowedUser!.notifications.items
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = false
        navigationController?.navigationBarHidden = false
        adaptNavTextColor()
    }
    
    func adaptNavTextColor() {
        if Session.shared.shadowedUser!.user.userColor!.shouldUseWhiteForeground() {
            UIApplication.sharedApplication().statusBarStyle = .LightContent
            navigationController!.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20)!
                ] as Dictionary<String, AnyObject>
            
        } else {
            UIApplication.sharedApplication().statusBarStyle = .Default
            navigationController!.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20)!
            ]
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        Async.main {
            self.tableView.reloadData()
        }
    }
    
    private func imageLayerForGradientBackground() -> UIImage {
        var updatedFrame = self.navigationController!.navigationBar.frame
        // take into account the status bar
        updatedFrame.size.height += 20
        let userColor = Session.shared.shadowedUser!.user.userColor!
        let color1 = userColor.darkenColor(0.1).CGColor
        let color2 = userColor.CGColor
        let layer = CAGradientLayer.gradientLayerForBounds(updatedFrame, colors: [color1, color2])
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageLabel.text = footerMessage
        tableView.dataSource = self
        tableView.delegate = self
        tableView.scrollsToTop = true
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetTableViewCell
//        let tweet = tweets[indexPath.row]
//        cell.loadWithTweet(tweet)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func refresh() {
        //
    }
}

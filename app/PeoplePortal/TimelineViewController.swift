//
//  TimelineViewController.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/22/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import DynamicColor
import Async

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tweetCellViewNib = UINib(nibName: "TweetCellView", bundle: nil)
        tableView.registerNib(tweetCellViewNib, forCellReuseIdentifier: "TweetCell")
        
        let retweetCellViewNib = UINib(nibName: "RetweetCellView", bundle: nil)
        tableView.registerNib(retweetCellViewNib, forCellReuseIdentifier: "RetweetCell")

        tableView.dataSource = self
        tableView.delegate = self
        tableView.scrollsToTop = true

        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
    }
    
    var refreshControl: UIRefreshControl?
    
    func refresh() {
        Session.shared.shadowedUser?.waitForWorkers([TimelineWorker.self]) {
            self.refreshControl?.endRefreshing()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var tweets : [Tweet] {
        get {
            return Session.shared.shadowedUser!.homeTimeline.items
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tweet = tweets[indexPath.row]
        var reuseIdentifier = "TweetCell"
        if tweet.isRetweet() {
            reuseIdentifier = "RetweetCell"
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        cell.loadWithTweet(tweet)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tweet = tweets[indexPath.row]
        var textHeight = tweet.calculateCellHeight(UIFont.systemFontOfSize(16), width: tableView.frame.size.width-80)
        if tweet.isRetweet() {
            textHeight += 15
        }
        return textHeight + 80
    }

}

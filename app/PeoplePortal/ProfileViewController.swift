//
//  ProfileViewController.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/18/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import Async

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileBackgroundView: UIImageView!
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var profileInfoView: UIScrollView!
    @IBOutlet weak var youAreLabel: UILabel!
    @IBOutlet weak var scrollViewControl: UIPageControl!
    
    var profileDescriptionTextView: UITextView?
    var adoptedCountLabel: UILabel?
    
    var user: User?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var switchButton: UIButton!
    
    var mainFlag: Bool = false
    
    func scrollToTop() {
        tableView.setContentOffset(CGPointZero, animated: true)
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func isMainProfileView() -> Bool {
//        return user == Session.shared.shadowedUser?.user
        return mainFlag
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        if tableView.contentOffset.y > 250.0 {
            UIApplication.sharedApplication().statusBarHidden = false
            navigationController?.navigationBarHidden = false
            
        } else {
            UIApplication.sharedApplication().statusBarHidden = false
            navigationController?.navigationBarHidden = true
        }
        
    }
    
    @IBAction func followingButtonPressed(sender: AnyObject) {
        if isMainProfileView() {
            performSegueWithIdentifier("UserListSegue", sender: sender)
        } else {
            user?.loadFollowing {
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("UsersList") as! UserTableViewController
                vc.source = self.user!.following
                vc.viewTitle = "Following"
                self.navigationController!.pushViewController(vc, animated: true)

            }
        }
    }
    
    @IBAction func followersButtonPressed(sender: AnyObject) {
        if isMainProfileView() {
            performSegueWithIdentifier("UserListSegue", sender: sender)
        } else {
            user?.loadFollowers {
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("UsersList") as! UserTableViewController
                vc.source = self.user!.followers
                vc.viewTitle = "Followers"
                self.navigationController!.pushViewController(vc, animated: true)

            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UserListSegue" {
            let dest = segue.destinationViewController as! UserTableViewController
            if sender?.tag == Constants.FOLLOWING_BUTTON_TAG {
                if self.isMainProfileView() {
                    dest.source = Session.shared.shadowedUser!.following.items
                } else {
                    dest.source = self.user?.following
                }
                dest.viewTitle = "Following"
            } else {
                if self.isMainProfileView() {
                    dest.source = Session.shared.shadowedUser!.followers.items
                } else {
                    dest.source = self.user?.followers
                }
                dest.viewTitle = "Followers"
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        Async.main {
            self.tableView.reloadData()
        }
    }
    
    func loadUserStuff() {
        if user!.profileBannerUrl != nil {
            profileBackgroundView.sd_setImageWithURL(NSURL(string: user!.profileBannerUrl!))
        }
        
        if isMainProfileView() {
            profileBackgroundView.backgroundColor = user!.userColor
        }
        
        if user!.profileImageUrl != nil {
            profileImageView.sd_setImageWithURL(NSURL(string: user!.profileImageUrlBigger!))
        }
        
        nameLabel.text = user!.name!
        screenNameLabel.text = "@\(user!.screenName!)"
        followingButton.setTitle("\(Utils.formatNumber(user!.friendCount!)) FOLLOWING", forState: .Normal)
        followersButton.setTitle("\(Utils.formatNumber(user!.followerCount!)) FOLLOWERS", forState: .Normal)
        
        self.navigationItem.title = "@\(user!.screenName!)"
        
        if isMainProfileView() {
            self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        }

        adaptNavTextColor()

    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        self.profileInfoView.scrollsToTop = false
        
        Async.main {
            self.user?.loadFollowing({})
            self.user?.loadFollowers({})
        }

//        tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 100))
        self.automaticallyAdjustsScrollViewInsets = false
//        self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);

        
        let tweetCellViewNib = UINib(nibName: "TweetCellView", bundle: nil)
        tableView.registerNib(tweetCellViewNib, forCellReuseIdentifier: "TweetCell")
        
        let retweetCellViewNib = UINib(nibName: "RetweetCellView", bundle: nil)
        tableView.registerNib(retweetCellViewNib, forCellReuseIdentifier: "RetweetCell")
        
//        let shadowedUser = Session.shared.shadowedUser!
        
//        Async.main {            
//            shadowedUser.start()
//        }
        
        
        nameLabel.sizeToFit()
        screenNameLabel.sizeToFit()
        followingButton.sizeToFit()
        followersButton.sizeToFit()
        
        profileImageView.backgroundColor = UIColor.clearColor()
        profileImageView.layer.cornerRadius = 5
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        profileImageView.layer.masksToBounds = true
        
        refreshControl = UIRefreshControl()
        refreshControl!.bounds = CGRectMake(refreshControl!.bounds.origin.x,
                                           20,
                                           refreshControl!.bounds.size.width,
                                           refreshControl!.bounds.size.height)
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)

        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        adaptNavTextColor()
        
        if isMainProfileView() {
            updateNotificationsButton()
            
        } else {
            youAreLabel.hidden = true
//            notificationsButton.hidden = true
//            switchButton.hidden = true

            loadBackButton()
        }
        
        self.headView.frame = CGRectMake(self.headView.frame.origin.x, self.headView.frame.origin.y, self.headView.frame.size.width, 300)
        
        print("bounds", self.view.frame.size.width)
        
        loadUserStuff()
        
//        self.profileInfoView.contentSize = CGSizeMake(self.view.frame.size.width*2, self.profileInfoView.frame.height)
//        scrollViewControl.addTarget(self, action: "changePage", forControlEvents: UIControlEvents.ValueChanged)

        addProfileInfoRest()
        
        self.profileInfoView.delegate = self
        
        navigationController?.interactivePopGestureRecognizer!.delegate = self
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if(navigationController?.viewControllers.count > 1){
            return true
        }
        return false
    }

    
    func peopleOrPerson(n: Int) -> String {
        if n == 1 {
            return "person has"
        } else {
            return "people have"
        }
    }
    
    func loadBackButton() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        backButton.hidden = false
    }
    
    func addProfileInfoRest() {
        let screenWidth = self.view.frame.size.width
        
        let profileDescriptionTextViewFrame = CGRectMake(0, 10, screenWidth-100, 120)
        profileDescriptionTextView = UITextView(frame: profileDescriptionTextViewFrame)
        profileDescriptionTextView?.center.x = (screenWidth*3)/2
        profileDescriptionTextView?.text = user?.profileDescription!
        profileDescriptionTextView?.textColor = UIColor.whiteColor()
        profileDescriptionTextView?.backgroundColor = UIColor.clearColor()
        profileDescriptionTextView?.font = UIFont.systemFontOfSize(15)
        profileDescriptionTextView?.textAlignment = .Center
        profileDescriptionTextView?.scrollEnabled = false
        profileDescriptionTextView?.editable = false
        profileDescriptionTextView?.selectable = false
        
        let adoptedCountLabelFrame = CGRectMake(0, 80, screenWidth-100, 100)
        adoptedCountLabel = UILabel(frame: adoptedCountLabelFrame)
        adoptedCountLabel?.center.x = (screenWidth*3)/2
        
        let nPeople = 0
        adoptedCountLabel?.text = "\(nPeople) \(peopleOrPerson(nPeople)) adopted this identity"
        adoptedCountLabel?.textColor = UIColor.whiteColor()
        adoptedCountLabel?.backgroundColor = UIColor.clearColor()
        adoptedCountLabel?.font = UIFont.boldSystemFontOfSize(14)
        adoptedCountLabel?.textAlignment = .Center
        
        self.profileInfoView.addSubview(profileDescriptionTextView!)
        self.profileInfoView.addSubview(adoptedCountLabel!)
    }
    
    func changePage(sender: AnyObject) -> () {
        let screenWidth = self.view.frame.size.width
        let x = CGFloat(scrollViewControl.currentPage) * screenWidth
        profileInfoView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        if scrollView == profileInfoView {
//            let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
//            scrollViewControl.currentPage = Int(pageNumber)
//        }
    }
    
    
    private func imageLayerForGradientBackground() -> UIImage {
        var updatedFrame = self.navigationController!.navigationBar.frame
        // take into account the status bar
        updatedFrame.size.height += 20
//        let userColor = Session.shared.shadowedUser!.user.userColor!
        let userColor = user!.userColor!
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
    
    func refresh() {
        if isMainProfileView() {
            Session.shared.shadowedUser?.waitForWorkers([ProfileWorker.self]) {
                Async.main {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    var tweets: [Tweet] {
        get {
            return user!.getTweets()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets.count == 0 { return 1 }
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tweets.count == 0 {
            let cell = UITableViewCell()
            if isMainProfileView() {
                cell.textLabel?.text = "You have not tweeted anything."
            } else {
                cell.textLabel?.text = "The user has not tweeted anything."
            }
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.font = UIFont.systemFontOfSize(15)
            cell.textLabel?.textColor = UIColor.darkGrayColor()
            cell.selectionStyle = .None
            return cell
        }
        
        let tweet = tweets[indexPath.row]
        var reuseIdentifier = "TweetCell"
        if tweet.isRetweet() {
            reuseIdentifier = "RetweetCell"
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        cell.loadWithTweet(tweet, origin: self)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tweets.count == 0 { return 50 }
        let tweet = tweets[indexPath.row]
        var textHeight = tweet.calculateCellHeight(UIFont.systemFontOfSize(15), width: tableView.frame.size.width-Constants.CELL_CONTENT_PADDING)
        if tweet.isRetweet() {
            textHeight += 15
        }
        return textHeight + 80
    }

    @IBAction func switchButtonPressed(sender: AnyObject) {
        let shadowedUser = Session.shared.shadowedUser!
        let hoursSinceSwitch = shadowedUser.hoursSinceSwitch()
        if hoursSinceSwitch < Constants.SWITCH_HOURS_MINIMUM {
            let alertController = UIAlertController(title: "Unable to Switch", message:
                "Sorry, you cannot become someone else so quickly. You need to wait \(Constants.SWITCH_HOURS_MINIMUM-hoursSinceSwitch) more hours.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("SelectionView")
        self.modalTransitionStyle = .FlipHorizontal
        self.modalPresentationStyle = .CurrentContext
        self.presentViewController(vc, animated: true, completion: {
            
        })
    }
    
    func adaptNavTextColor() {
        if !isMainProfileView() {
            return
        }
        
        if user!.userColor!.shouldUseWhiteForeground() {
            UIApplication.sharedApplication().statusBarStyle = .LightContent
            navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20)!
                ] as Dictionary<String, AnyObject>
            
        } else {
            UIApplication.sharedApplication().statusBarStyle = .Default
            navigationController?.navigationBar.tintColor = UIColor.blackColor()
            navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20)!
            ]
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if tableView.contentOffset.y > 250.0 {
            UIApplication.sharedApplication().statusBarHidden = false
            navigationController?.navigationBarHidden = false
            adaptNavTextColor()
            
        } else {
            UIApplication.sharedApplication().statusBarHidden = false
            navigationController?.navigationBarHidden = true
            UIApplication.sharedApplication().statusBarStyle = .LightContent
        }
    }
    
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var notificationsBarButton: UIBarButtonItem!
    
    func updateNotificationsButton() {
//        if Session.shared.notificationsEnabled {
//            notificationsButton.setImage(UIImage(named: "notifications_enabled"), forState: .Normal)
//            notificationsBarButton.image = UIImage(named: "notifications_enabled_bar_button")
//            
//        } else {
//            notificationsButton.setImage(UIImage(named: "notifications_disabled"), forState: .Normal)
//            notificationsBarButton.image = UIImage(named: "notifications_disabled_bar_button")
//
//        }
    }
    
    @IBAction func notificationsButtonPressed(sender: AnyObject) {
        var headerMessage: String?
        var actionMessage: String?
        
        if Session.shared.notificationsEnabled {
            headerMessage = "Notifications are currently enabled."
            actionMessage = "Disable notifications"

        } else {
            headerMessage = "Notifications are currently disabled."
            actionMessage = "Enable notifications"

        }
        
        let menu = UIAlertController(title: nil, message: headerMessage, preferredStyle: .ActionSheet)

        let changeAction = UIAlertAction(title: actionMessage, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Change")
            Session.shared.notificationsEnabled = !Session.shared.notificationsEnabled
            self.updateNotificationsButton()

        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })

        menu.addAction(changeAction)
        menu.addAction(cancelAction)
        
        self.presentViewController(menu, animated: true, completion: {
        })
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        print("section:", section)
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("did select!")
//        let tweet = self.tweets[indexPath.row]
//        tweet.loadReplies {
//            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("TweetConversation") as! TweetConversationTableViewController
//            vc.mainTweet = tweet
//            vc.conversation = tweet.getConversation()
//            self.navigationController!.pushViewController(vc, animated: true)
//            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
    }

}

//
//  BecomingViewController.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 11/13/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import Async

class BecomingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tweetTableView: UITableView!
    @IBOutlet weak var becomeButton: UIButton!
    @IBOutlet weak var latestTweetLabel: UILabel!
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tweetCellViewNib = UINib(nibName: "TweetCellView", bundle: nil)
        tweetTableView.registerNib(tweetCellViewNib, forCellReuseIdentifier: "TweetCell")
        
        let retweetCellViewNib = UINib(nibName: "RetweetCellView", bundle: nil)
        tweetTableView.registerNib(retweetCellViewNib, forCellReuseIdentifier: "RetweetCell")
        
        tweetTableView.dataSource = self
        tweetTableView.delegate = self
        tweetTableView.layer.cornerRadius = 5
        tweetTableView.layer.masksToBounds = true

        nameLabel.text = user?.name
        screenNameLabel.text = "@\(user!.screenName!)"
        
        becomeButton.setTitle("Become @\(user!.screenName!)", forState: .Normal)
        becomeButton.layer.borderWidth = 3
        becomeButton.layer.borderColor = UIColor(hexString: "#E8F4F2").CGColor
        becomeButton.layer.cornerRadius = 5

        profileImageView.sd_setImageWithURL(NSURL(string: self.user!.profileImageUrlBigger!))
        profileImageView.backgroundColor = UIColor.clearColor()
        profileImageView.layer.cornerRadius = 5
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        
        Async.background {
            self.loadTweet()
        }
    }

    override func viewDidLayoutSubviews() {
        if lastTweet != nil {
            let tweet = lastTweet!
            var textHeight = tweet.calculateCellHeight(UIFont.systemFontOfSize(16), width: tweetTableView.frame.size.width-80)
            if tweet.isRetweet() {
                textHeight += 15
            }
            
            var frame = self.tweetTableView.frame
            frame.size.height = textHeight + 80
            self.tweetTableView.frame = frame
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    var lastTweet: Tweet?
    
    func loadTweet() {
        let uid = user?.userIdString
        
        Session.shared.swifter!.getStatusesUserTimelineWithUserID(uid!, count: 200, sinceID: nil, maxID: nil, trimUser: false, contributorDetails: false, includeEntities: false, success: {
            statuses in
            
            if statuses!.count > 0 {
                self.lastTweet = Tweet.deserializeJSON(statuses![0].object!)
            }
            
            self.activityIndicator.stopAnimating()

            self.tweetTableView.hidden = false

            self.tweetTableView.alpha = 0
            
            UIView.animateWithDuration(0.5, animations: {
                self.tweetTableView.alpha = 1
            })
            
            Async.main {
                self.tweetTableView.reloadData()
            }
            
            }, failure: {
                error in
                
                print("ERROR: \(error)")
        })

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if lastTweet != nil { return 1 }
        else { return 0 }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tweet = lastTweet!
        var reuseIdentifier = "TweetCell"
        if tweet.isRetweet() {
            reuseIdentifier = "RetweetCell"
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        cell.loadWithTweet(tweet)
        cell.timeAgoLabel.hidden = true
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tweet = lastTweet!
        var textHeight = tweet.calculateCellHeight(UIFont.systemFontOfSize(16), width: tableView.frame.size.width-80)
        if tweet.isRetweet() {
            textHeight += 15
        }
        
        var frame = self.tweetTableView.frame
        frame.size.height = textHeight + 80
        self.tweetTableView.frame = frame
        
        return textHeight + 80
    }
    
    @IBAction func becomeButtonPressed(sender: AnyObject) {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: false)
        hud.mode = .Indeterminate
//        hud.labelText = "Becoming @\(user!.screenName!)"
        Session.shared.become(user!) {
            Async.main {
                hud.hide(false)
                Session.shared.save()
                Session.shared.shadowedUser!.markAllAsSeen()
                self.transitionToMain()
            }
            
        }
    }
    
    func transitionToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("MainView")
        let window = UIApplication.sharedApplication().delegate?.window!!
        
        UIView.transitionWithView(window!, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: {
            window!.rootViewController = vc
            }, completion: nil)
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

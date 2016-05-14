//
//  UserProfileViewController.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 07/04/16.
//  Copyright © 2016 Anastasis Germanidis. All rights reserved.
//

import UIKit
import Async

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var followingLabel: UIButton!
    @IBOutlet weak var followersLabel: UIButton!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var user: User?
    var tweets: [Tweet]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func loadUser(userToLoad:User) {
        self.user = userToLoad
        self.user?.loadTimeline({
            userTweets in
            self.tweets = userTweets
            self.tableView.reloadData()
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tweets != nil {
            return self.tweets!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tweet = self.tweets![indexPath.row]
        var reuseIdentifier = "TweetCell"
        if tweet.isRetweet() {
            reuseIdentifier = "RetweetCell"
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        cell.loadWithTweet(tweet, origin: self)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tweet = self.tweets![indexPath.row]
        var textHeight = tweet.calculateCellHeight(UIFont.systemFontOfSize(16), width: tableView.frame.size.width-80)
        if tweet.isRetweet() {
            textHeight += 15
        }
        return textHeight + 80
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
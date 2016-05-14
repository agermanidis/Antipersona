//
//  TweetTableViewCell.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/19/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetContentView: UITextView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var retweetIndicator: UIImageView!
    @IBOutlet weak var retweetLabel: UILabel!
    
    var originalTweet: Tweet?
    var vcOrigin: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 5.0
        profileImageView.layer.masksToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func loadWithTweet(tweet: Tweet, origin: UIViewController) {
        vcOrigin = origin
        
        if tweet.isRetweet() {
            originalTweet = tweet.retweetedStatus!
        } else {
            originalTweet = tweet
        }
        
        nameLabel.text = originalTweet!.user?.name
        screenNameLabel.text = "@\(originalTweet!.user!.screenName!)"
        timeAgoLabel.text = originalTweet!.ctime?.shortTimeAgoSinceNow()
        timeAgoLabel.sizeToFit()
        tweetContentView.setSafeText(originalTweet!.text!)
//        tweetContentView.selectable = false
//        tweetContentView.editable = false
        favoriteCountLabel.text = Utils.formatNumber(originalTweet!.favoriteCount!)
        retweetCountLabel.text = Utils.formatNumber(originalTweet!.retweetCount!)

        if tweet.isRetweet() {
            retweetIndicator.image = UIImage(named: "retweet")

            profileImageView.sd_setImageWithURL(NSURL(string: tweet.retweetedStatus!.user!.profileImageUrl!))
            if Session.shared.shadowedUser?.user.userId == tweet.user?.userId {
                retweetLabel.text = "You retweeted"
            } else {
                retweetLabel.text = "Retweeted by \(tweet.user!.name!)"
            }
            retweetLabel.sizeToFit()
            
        } else if tweet.isReply() {
            retweetIndicator.image = UIImage(named: "inreplyto")
            retweetLabel.text = "in reply to \(tweet.inReplyTo!.user!.name)"
            profileImageView.sd_setImageWithURL(NSURL(string: tweet.user!.profileImageUrl!))
            
        }else {
            profileImageView.sd_setImageWithURL(NSURL(string: tweet.user!.profileImageUrl!))
        }
        
        let imageTap = UITapGestureRecognizer(target: self, action: "profileImageTapped")
        profileImageView.userInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
    }
    
    func profileImageTapped() {
        let user = originalTweet?.user

        if self.vcOrigin is ProfileViewController {
            let vc = self.vcOrigin as! ProfileViewController
            if vc.user == user {
                return
            }
        }
        
        user!.loadTimeline({
            tweets in
            let vc = self.vcOrigin?.storyboard!.instantiateViewControllerWithIdentifier("Profile") as! ProfileViewController
            vc.user = user
            self.vcOrigin!.navigationController!.pushViewController(vc, animated: true)
        })
    }

}

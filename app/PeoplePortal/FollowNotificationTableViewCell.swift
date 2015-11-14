//
//  FollowNotificationTableViewCell.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/24/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class FollowNotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var follower1ImageView: UIImageView!
    @IBOutlet weak var follower2ImageView: UIImageView!
    @IBOutlet weak var follower3ImageView: UIImageView!
    @IBOutlet weak var follower4ImageView: UIImageView!
    @IBOutlet weak var follower5ImageView: UIImageView!
    @IBOutlet weak var follower6ImageView: UIImageView!
    
    var followerImageViews: [UIImageView] {
        get {
            return [
                follower1ImageView,
                follower2ImageView,
                follower3ImageView,
                follower4ImageView,
                follower5ImageView,
                follower6ImageView,
            ]
        }
    }
    @IBOutlet weak var notificationTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutMargins = UIEdgeInsetsZero
        for view in followerImageViews {
            view.layer.cornerRadius = 5.0
        }
    }
    
    static func calculateCellHeight(notification: Notification) -> CGFloat {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let result = notification.attributedText!.boundingRectWithSize(CGSizeMake(screenWidth-80, CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], context: nil).height
        return 60+result*1.3
    }

    func loadWithNotification(notification: Notification) {
        notificationTextLabel.attributedText = notification.attributedText
        let users = notification.users!
        for i in 0..<min(users.count, followerImageViews.count) {
            let user = users[i]
            let imageView = followerImageViews[i]
            imageView.sd_setImageWithURL(NSURL(string: user.profileImageUrlBigger!))
        }
        if followerImageViews.count > users.count {
            for i in users.count..<followerImageViews.count {
                followerImageViews[i].image = nil
            }
        }
    }

}

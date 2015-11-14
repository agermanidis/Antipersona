//
//  RetweetNotificationTableViewCell.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/24/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class RetweetNotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var retweeter1ImageView: UIImageView!
    @IBOutlet weak var retweeter2ImageView: UIImageView!
    @IBOutlet weak var retweeter3ImageView: UIImageView!
    @IBOutlet weak var retweeter4ImageView: UIImageView!
    @IBOutlet weak var retweeter5ImageView: UIImageView!
    @IBOutlet weak var retweeter6ImageView: UIImageView!
    
    var retweeterImageViews: [UIImageView] {
        get {
            return [
                retweeter1ImageView,
                retweeter2ImageView,
                retweeter3ImageView,
                retweeter4ImageView,
                retweeter5ImageView,
                retweeter6ImageView,
            ]
        }
    }

    @IBOutlet weak var notificationTextLabel: UILabel!
    @IBOutlet weak var originalStatusTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutMargins = UIEdgeInsetsZero
        for view in retweeterImageViews {
            view.layer.cornerRadius = 5.0
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static func calculateCellHeight(notification: Notification) -> CGFloat {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let result = notification.attributedText!.boundingRectWithSize(CGSizeMake(screenWidth-80, CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], context: nil).height
        let originalStatusTextViewFont = UIFont(name: "HelveticaNeue", size: 13)
        return 60+result*1.3+notification.tweet!.calculateCellHeight(originalStatusTextViewFont!, width: screenWidth-80)*1.3
    }

    func loadWithNotification(notification: Notification) {
        notificationTextLabel.attributedText = notification.attributedText
        originalStatusTextView.text = notification.tweet?.text
        var frame = originalStatusTextView.frame
        frame.size.height = originalStatusTextView.contentSize.height
        originalStatusTextView.frame = frame
        let users = notification.otherTweets!.map({$0.user!})
        for i in 0..<min(users.count, retweeterImageViews.count) {
            let user = users[i]
            let imageView = retweeterImageViews[i]
            imageView.sd_setImageWithURL(NSURL(string: user.profileImageUrlBigger!))
        }
        if retweeterImageViews.count > users.count {
            for i in users.count..<retweeterImageViews.count {
                retweeterImageViews[i].image = nil
            }
        }
    }

}

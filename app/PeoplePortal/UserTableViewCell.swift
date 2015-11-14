//
//  UserTableViewCell.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/16/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import SDWebImage

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var screenName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.layer.cornerRadius = 5.0
        profilePicture.layer.masksToBounds = true
        layoutMargins = UIEdgeInsetsZero
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func loadWithUser(user: User) {
        profilePicture.sd_setImageWithURL(NSURL(string: user.profileImageUrl!))
        name.text = user.name
        screenName.text = "@\(user.screenName!)"
    }
}

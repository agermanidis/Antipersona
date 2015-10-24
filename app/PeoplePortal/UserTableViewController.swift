//
//  UserTableViewController.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/19/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {
    var source : [User]?
    var viewTitle : String?
    @IBOutlet weak var footerMessageLabel: UILabel!
    
    var footerMessage: String {
        get {
            if source?.count > 0 {
                return ""
            } else {
                return "No users to display"
            }
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        footerMessageLabel.text = footerMessage
    }

    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationItem.title = viewTitle
        adaptNavTextColor()
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserTableViewCell
        cell.loadWithUser(source![indexPath.row])
        return cell
    }
}

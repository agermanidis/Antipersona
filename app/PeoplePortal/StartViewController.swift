//
//  StartViewController.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/14/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import SafariServices
import Accounts
import Async


class StartViewController: UIViewController, SFSafariViewControllerDelegate {
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.layer.borderWidth = 3
        startButton.layer.borderColor = UIColor(hexString: "#E8F4F2").CGColor
        startButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func authorize() {
        let url = NSURL(string: "swifter://success")!
        
        let failureHandler: ((NSError) -> Void) = {
            error in
            print(error)
        }
        
        Session.shared.swifter!.authorizeWithCallbackURL(url, success: { (accessToken, response) -> Void in
            Session.shared.credentials = TwitterCredentials(
                accessToken: accessToken!.key,
                accessSecret: accessToken!.secret
            )
            
            }, failure: failureHandler,
            openQueryURL: { (url) -> Void in
                let webView = SFSafariViewController(URL: url)
                webView.delegate = self
                self.presentViewController(webView, animated: true, completion: nil)
            }, closeQueryURL: { () -> Void in
                print("close query url")
                self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    @IBAction func startButtonPressed(sender: AnyObject) {
        authorize()
    }
    
    func transitionToSearch() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("SelectionView")
        let window = UIApplication.sharedApplication().delegate?.window!!
        
        UIView.transitionWithView(window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            window!.rootViewController = vc
            }, completion: nil)
    }
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        NSNotificationCenter.defaultCenter().removeObserver(Session.shared.swifter!, name: "SwifterCallbackNotificationName", object: nil)
        controller.dismissViewControllerAnimated(true, completion: nil)
        print("authorized")
    }
    
    func selectTwitterAccountDialog(accounts: [ACAccount]) {
        let menu = UIAlertController(title: nil, message: "Select a Twitter account", preferredStyle: .ActionSheet)
        
        for account in accounts {
            let accountAction = UIAlertAction(title: "@\(account.username)", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.loginWithAccount(account)
            })
            menu.addAction(accountAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        menu.addAction(cancelAction)
        
        self.presentViewController(menu, animated: true, completion: {
        })
    }
    
    func loginWithAccount(account: ACAccount) {
        print("logging in with \(account.username)")
        Session.shared.twitterAccountIdentifier = account.identifier
    }
    
    func showError(title: String, message: String) {
        Async.main {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
}

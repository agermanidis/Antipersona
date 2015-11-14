//
//  StartViewController.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/14/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import SafariServices

class StartViewController: UIViewController {

    @IBOutlet weak var errorMessage: UILabel!
    
    var swifter: Swifter?
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.layer.borderWidth = 3
        startButton.layer.borderColor = UIColor(hexString: "#E8F4F2").CGColor
        startButton.layer.cornerRadius = 5

        
        self.swifter = Swifter(
            consumerKey: Constants.TWITTER_CONSUMER_KEY,
            consumerSecret: Constants.TWITTER_CONSUMER_SECRET
        )
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
        
        self.swifter!.authorizeWithCallbackURL(url, success: { (accessToken, response) -> Void in
            print(accessToken)
            
//            self.fetchTwitterHomeStream()
            }, failure: failureHandler,
            openQueryURL: { (url) -> Void in
                let webView = SFSafariViewController(URL: url)
//                    webView.delegate = self
                self.presentViewController(webView, animated: true, completion: nil)
            }, closeQueryURL: { () -> Void in
                self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    @IBAction func startButtonPressed(sender: AnyObject) {
//        authorize()
        
        // no accounts
        // no access
        
        self.transitionToSearch()
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
        NSNotificationCenter.defaultCenter().removeObserver(self.swifter!, name: "SwifterCallbackNotificationName", object: nil)
//        controller.dismissViewControllerAnimated(true, completion: nil)
        print("authorized")
    }
    
    func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

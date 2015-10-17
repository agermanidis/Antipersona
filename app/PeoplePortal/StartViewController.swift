//
//  StartViewController.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/14/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func authorize() {
        // show loading indicator

        let swifter = Swifter(
            consumerKey: Constants.TWITTER_CONSUMER_KEY,
            consumerSecret: Constants.TWITTER_CONSUMER_SECRET
        )
        
        swifter.authorizeAppOnlyWithSuccess({
            (credentials: SwifterCredential.OAuthAccessToken?, response: NSURLResponse) in

            let accessToken = credentials!.key
            let accessSecret = credentials!.secret
            Session.shared.credentials = TwitterCredentials(
                    accessToken: accessToken,
                    accessSecret: accessSecret
            )
        },
        failure: {
            (error: NSError) in
            self.errorMessage.text = "You have not given permission to access Twitter"
        })
    }
}

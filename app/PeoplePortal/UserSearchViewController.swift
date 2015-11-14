//
//  UserSearchTableViewController.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/16/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import Async

class UserSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var searchResults: [User] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var searchQuery: String = "" {
        didSet {
            self.searchBar.showsCancelButton = !defaultMode
            self.searchCountdown()
            if searchQuery.characters.count == 0 {
                self.searchResults = []
            }
            self.tableView.reloadData()
            
        }
    }
    var defaultResults: [User] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var searchMode = false {
        didSet {
            self.searchBar.showsCancelButton = !defaultMode
            self.tableView.reloadData()
        }
    }
    var tableResults: [User] {
        get {
            if searchQuery.characters.count > 0 {
                return searchResults
            } else {
                return defaultResults
            }            
        }
    }
    var defaultMode : Bool {
        get {
            return !searchMode && searchQuery.characters.count == 0
        }
    }
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var loadingIndicator: UIActivityIndicatorView?
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self

        if self.isModal() {
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "dismiss")
            cancelButton.tintColor = UIColor.whiteColor()
            navigationItem.leftBarButtonItem = cancelButton
        }
       
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        loadingIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        loadingIndicator?.activityIndicatorViewStyle = .WhiteLarge
        loadingIndicator?.color = UIColor.grayColor()
        loadingIndicator?.center = CGPointMake(self.view.center.x, 100)
        self.tableView.addSubview(loadingIndicator!)
        
        loadingIndicator?.startAnimating()
        loadingIndicator?.hidesWhenStopped = true
        
        retrieveFollowing()
    }
    
    func dismiss() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func isModal() -> Bool {
        if((self.presentingViewController) != nil) {
            return true
        }
        
        if(self.presentingViewController?.presentedViewController == self) {
            return true
        }
        
        if(self.navigationController?.presentingViewController?.presentedViewController == self.navigationController) {
            return true
        }
        
        if((self.tabBarController?.presentingViewController?.isKindOfClass(UITabBarController)) != nil) {
            return true
        }
        
        return false
    }
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    func retrieveFollowing() {
        Async.background {
            print("Retrieving following")
            if Session.shared.following != nil {
                print("It's cached")
                
                Async.main {
                    self.defaultResults = Session.shared.following!
                    self.loadingIndicator?.stopAnimating()

                }
                return
            }
        Session.shared.swifter?.getFriendsListWithID(String(300084023), cursor: nil, count: 200, success: {
                users, previousCursor, nextCursor in
                
                print("count of users")
                print(users!.count)
                
                self.loadingIndicator?.stopAnimating()
                let following = users!.map({ User.deserializeJSON($0.object!) })
                self.defaultResults = following
                Session.shared.following = following
                
                }, failure: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableResults.count
    }    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserSearchCell", forIndexPath: indexPath) as! UserTableViewCell
        let user = tableResults[indexPath.row]
        cell.loadWithUser(user)
        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchQuery.characters.count == 0 {
            return "Following"
        } else {
            return nil
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchQuery = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print("search text did change", searchText)
        searchQuery = searchText
    }

    func performSearch() {
        print("perform search")
        if searchQuery.characters.count == 0 { return }

        let currentSearchQuery = searchQuery        
        
        Session.shared.swifter?.getUsersSearchWithQuery(searchQuery, page: 0, count: 20, includeEntities: false, success: {
            users in
            self.loadingIndicator?.stopAnimating()

            if self.searchQuery != currentSearchQuery { return }
            
            self.searchResults = users!.map({ User.deserializeJSON($0.object!) }).filter({ !$0.protected! })
            
            }, failure: {
                error in
           
        })
    }

    var debounceTimer: NSTimer?
    func searchCountdown() {
        print("search countdown")
        if let timer = debounceTimer {
            timer.invalidate()
        }
        
        print(searchQuery.characters.count)
        if searchQuery.characters.count == 0 {
            return 
        }
        
        debounceTimer = NSTimer(timeInterval: 0.3, target: self, selector: Selector("performSearch"), userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(debounceTimer!, forMode: "NSDefaultRunLoopMode")
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchMode = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchMode = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    private func imageLayerForGradientBackground() -> UIImage {
        var updatedFrame = self.navigationController!.navigationBar.frame
        // take into account the status bar
        updatedFrame.size.height += 20
        let color1 = UIColor(red: 108.0/255.0, green: 40.0/255.0, blue: 221.0/255.0, alpha: 1.0).CGColor
        let color2 = UIColor(red: 67.0/255.0, green: 117.0/255.0, blue: 178.0/255.0, alpha: 1.0).CGColor
        let layer = CAGradientLayer.gradientLayerForBounds(updatedFrame, colors: [color1, color2])
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
        
    var selectedUser: User?
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.selectedUser = tableResults[indexPath.row] 
        self.performSegueWithIdentifier("SearchToBecoming", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SearchToBecoming" {
            let dest = segue.destinationViewController as! BecomingViewController
            dest.user = selectedUser
        }
    }
}

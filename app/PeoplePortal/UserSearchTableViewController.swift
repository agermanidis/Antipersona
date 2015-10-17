//
//  UserSearchTableViewController.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/16/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class UserSearchTableViewController: UITableViewController, UISearchBarDelegate {
    var searchResults: [User] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var searchQuery: String = "" {
        didSet {
            self.searchCountdown()
        }
    }
    var defaultResults: [User] {
        get {
            return Session.shared.following ?? []
        }
    }
    var searchMode: Bool {
        get {
            return searchQuery.characters.count > 0
        }
    }
    var tableResults: [User] {
        get {
            if searchMode {
                return searchResults
            } else {
                return defaultResults
            }            
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableResults.count
    }    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserSearchCell", forIndexPath: indexPath) as! UserTableViewCell
        let user = tableResults[indexPath.row]
        cell.loadWithUser(user)
        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchMode {
            return nil
        } else {
            return "Following"
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
    }

    func performSearch() {
        Session.shared.swifter?.getUsersSearchWithQuery(searchQuery, page: 0, count: 20, includeEntities: false, success: {
            users in
            
            self.searchResults = users!.map({ User.deserializeJSON($0.object!) })
            
            }, failure: {
                error in
           
        })
    }

    var debounceTimer: NSTimer?
    func searchCountdown() {
        if searchQuery.characters.count == 0 {
            return 
        }
        if let timer = debounceTimer {
            timer.invalidate()
        }
        debounceTimer = NSTimer(timeInterval: 2.0, target: self, selector: Selector("performSearch"), userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(debounceTimer!, forMode: "NSDefaultRunLoopMode")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

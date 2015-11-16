//
//  ListTableViewController.swift
//  On-The-Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class ListTableViewController: UITableViewController {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let session = NSURLSession.sharedSession()
    var locations = [StudentInformation]()

    /* MARK : Lifecycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Add refresh control, which is activated when pulling down on the tableview */
        self.refreshControl?.addTarget(self, action: "refreshDataFromParse:", forControlEvents: .ValueChanged)
        
        if let locations = ParseClient.sharedInstance().studentData {
            self.locations = locations
        }
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if ParseClient.sharedInstance().studentData != nil {
            
            tableView.reloadData()
            
        } else {
            
            refreshDataFromParse(self)
            
        }
    }
    
    /* Reload table view data from Parse with callback */
    @IBAction func refreshDataFromParse(sender: AnyObject) {
        
        /* Show progress while submitting data */
        ParseClient.sharedInstance().studentData = nil
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading Data..."
        view.alpha = 0.4
        
        ParseClient.sharedInstance().getDataFromParse({ success, results, error in
            
            if success {
                /* Callback to caller saying that it was successful and we should hide the HUD */
                
                dispatch_async(GlobalMainQueue, {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.view.alpha = 1.0
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    
                    /* Assign local locations to be up-to-date */
                    if let locations = ParseClient.sharedInstance().studentData {
                        self.locations = locations
                    }
                })
            } else {
                /* Callback to caller saying that it was successful and we should hide the HUD */
                
                dispatch_async(GlobalMainQueue, {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.view.alpha = 1.0
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.alertController(withTitles: ["OK", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in
                        self.refreshDataFromParse(self)
                    }])
                    
                })
                
            }
            
        })
        
    }
    
}

/* Extends list table view controller with appropriate delegate methods for tableView */
extension ListTableViewController {
    
    /* Open media url when detail indicator selected only if valid URL */
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let sharedApplication = UIApplication.sharedApplication()

        if let URL = NSURL(string: locations[indexPath.row].MediaUrl) {
            
            sharedApplication.openURL(URL)

        } else {

            dispatch_async(GlobalMainQueue, {
                self.alertController(withTitles: ["Ok"], message: GlobalErrors.InvalidURL.localizedDescription, callbackHandler: [nil])
            })
            
        }

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as! LocationTableViewCell

         let data = locations[indexPath.row]
        
        cell.mainTextLabel.text = "\(data.First) \(data.Last)"
        cell.urlTextLabel.text = "\(data.MediaUrl)"
        cell.geoTextLabel.text = "From: \(data.GEODescriptor) at: \(data.UpdateTime)"
        

        cell.mainImageView.image = UIImage(named: "map")
        
        
        return cell
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
}

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


    /* MARK : Lifecycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Add refresh control, which is activated when pulling down on the tableview */
        self.refreshControl?.addTarget(self, action: "refreshDataFromParse:", forControlEvents: .ValueChanged)
        
        
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
    
    
    /* Open link if it is valid, or else notify user */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sharedApplication = UIApplication.sharedApplication()
        
        if ParseClient.sharedInstance().studentData != nil {
        
            if let urlString = ParseClient.sharedInstance().studentData![indexPath.row].MediaUrl {
                
                if urlString.containsString("http://") || urlString.containsString("https://") {
                    
                    if let URL = NSURL(string: ParseClient.sharedInstance().studentData![indexPath.row].MediaUrl) {
                        
                        sharedApplication.openURL(URL)
                        
                    }
                } else {
                    dispatch_async(GlobalMainQueue, {
                        self.alertController(withTitles: ["Ok"], message: GlobalErrors.InvalidURL.localizedDescription, callbackHandler: [nil])
                    })
                    
                }
                
            }
            
        }
    }
    
    /* Create and return the tableview cell */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as! LocationTableViewCell
        
        if ParseClient.sharedInstance().studentData != nil {
            let data = ParseClient.sharedInstance().studentData![indexPath.row]
        
            cell.mainTextLabel.text = "\(data.First) \(data.Last)"
            cell.urlTextLabel.text = "\(data.MediaUrl)"
            cell.geoTextLabel.text = "From: \(data.GEODescriptor) at: \(data.UpdateTime)"
        

            cell.mainImageView.image = UIImage(named: "map")
        }
        
        return cell
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ParseClient.sharedInstance().studentData != nil {
            return ParseClient.sharedInstance().studentData!.count
        } else {
            return 0
        }
    }
}

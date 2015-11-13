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
    var locations = [StudentLocationData]()
    let hud = MBProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: "refreshDataFromParse:", forControlEvents: .ValueChanged)
        
        /* Show hud when reloading */
        
        hud.labelText = "Loading..."
        
        hud.showWhileExecuting("refreshDataFromParse:", onTarget: self, withObject: hud, animated: true)
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let locations = ParseClient.sharedInstance().studentData {
            
            tableView.reloadData()
            
        } else {
            
            refreshDataFromParse(self)
            
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    /* reload table view data */
    @IBAction func refreshDataFromParse(sender: AnyObject) {
        
        ParseClient.sharedInstance().getDataFromParse({ success, results, error in
            
            self.hud.hide(true)
            
            if success {
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    
                })
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: {Void in
                        self.refreshDataFromParse(self)
                    })
                    
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                    
                    self.alertUserWithWithActions("Error loading", message: "Sorry, but there was an error loading the data from the network", actions: [retryAction, dismissAction])
                    
                })
                
            }
            
        })
        
        
    }

    
    /* Open media url when detail indicator selected */
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        let sharedApplication = UIApplication.sharedApplication()
        
        if let URLString = locations[indexPath.row].MediaUrl {
            
            sharedApplication.openURL(NSURL(string: URLString)!)
            
        } else {
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertUserWithWithActions("Failed to open link", message: "Sorry, but we couldn't open that link.", actions: [okAction])
            
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as! LocationTableViewCell

         let data = locations[indexPath.row]
        
        cell.mainTextLabel.text = "\(data.First) \(data.Last)"
        cell.urlTextLabel.text = "\(data.MediaUrl)"
        cell.geoTextLabel.text = "From: \(data.GEODescriptor) at: \(data.UpdateTime)"
        
        if let userImage = data.userImageURL as? NSData {
            cell.mainImageView.image = UIImage(data: userImage)
        } else {
            cell.mainImageView.image = UIImage(named: "identicon")
        }
        
        cell.accessoryView = UIImageView(image: UIImage(named: "safari-icon"))
        
        return cell
    }


}

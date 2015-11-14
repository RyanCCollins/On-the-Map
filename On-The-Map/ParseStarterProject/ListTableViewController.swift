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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: "didTapRefresh:", forControlEvents: .ValueChanged)
        
        if let locations = ParseClient.sharedInstance().studentData {
            self.locations = locations
        }
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if ParseClient.sharedInstance().studentData != nil {
            
            tableView.reloadData()
            
        } else {
            
            didTapRefresh(self)
            
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    @IBAction func didTapRefresh(sender: AnyObject) {
        
        /* Show progress while submitting data */
        ParseClient.sharedInstance().studentData = nil
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Reloading..."
        refreshDataFromParse({
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.refreshControl?.endRefreshing()
        })
        
    }
    
    /* reload table view data */
    func refreshDataFromParse(completionCallback: (()-> Void)?) {
        
        ParseClient.sharedInstance().getDataFromParse({ success, results, error in
            
            if success {
                
                if let locations = ParseClient.sharedInstance().studentData {
                    self.locations = locations
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    
                })
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: {Void in
                        self.refreshDataFromParse(nil)
                    })
                    
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                    
                    self.alertUserWithWithActions("Error loading", message: "Sorry, but there was an error loading the data from the network", actions: [retryAction, dismissAction])
                    
                })
                
            }
            
        })
        
        completionCallback!()
        
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
        
        if locations[indexPath.row].ImageURL != nil {
            if let userImage = NSData(contentsOfURL: locations[indexPath.row].ImageURL!) {
                print(userImage)
                cell.mainImageView.image = UIImage(data: userImage)
            }
        } else {
            cell.mainImageView.image = UIImage(named: "identicon")
        }

        
        cell.accessoryView = UIImageView(image: UIImage(named: "safari-icon"))
        
        return cell
    }


}

//
//  ListTableTableViewController.swift
//  On-The-Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import Parse
class ListTableTableViewController: UITableViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let session = NSURLSession.sharedSession()
    var locations = [StudentLocationData]()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(animated: Bool) {
        loadWithParseData({success, error in
            if let error = error {
                print(error)
            }
        })
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    
    /* add parse data to list if first time logging in, get the data, if not, get the shared instance of student data */
    func loadWithParseData(completionHandler: (success: Bool, error: NSError?)-> Void) {
        
            /* reload data if refreshing */
            if let locations = ParseClient.sharedInstance().studentData {
                self.locations = locations
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })

                completionHandler(success: true, error: nil)
                
            /* Otherwise, fetch the data */
            } else {
                ParseClient.sharedInstance().getDataFromParse({success, results, error in
                    
                    if success {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                        completionHandler(success: true, error: nil)
                        
                    } else {
                        
                        completionHandler(success: false, error: self.errorFromString("Failed to load map with parsed data in loadMapWithParsedData"))
                    
                    }
                    
                })
            }
            
            
            completionHandler(success: true, error: nil)
        
    }
    
    /* refresh the view for data update/retrieval - call asynchronouslt*/
    func refreshViewForDataUpdate() {
        
        dispatch_async(dispatch_get_main_queue(), {
//            self.activityIndicator.startAnimating()
//            self.activityIndicator.alpha = 1.0
        })
        
        loadWithParseData({ success, error in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
//                    self.activityIndicator.stopAnimating()
//                    self.activityIndicator.alpha = 1.0
                })
                
            } else {
                
                let logoutAction = UIAlertAction(title: "Logout", style: .Destructive, handler: { Void in
                    self.logoutOfSession()
                })
                let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: { Void in
                    self.refreshDataFromParse()
                })
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.alertUserWithWithActions("Failed to refresh data", message: "Something went wrong while refreshing the data.  Please retry or logout", actions: [logoutAction, retryAction])
                    
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
        cell.geoTextLabel.text = "Posted from: \(data.GEODescriptor)"
        
        if let userImage = data.userImageURL as? NSData {
            cell.mainImageView.image = UIImage(data: userImage)
        } else {
            cell.mainImageView.image = UIImage(named: "identicon")
        }

        return cell
    }


}

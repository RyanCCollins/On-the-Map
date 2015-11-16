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
                
                dispatch_async(GlobalMainQueue, {
                    self.tableView.reloadData()
                })
                
            } else {
                
                dispatch_async(GlobalMainQueue, {
                    
                    self.alertController(withTitles: ["OK", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in
                        self.refreshDataFromParse({
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            self.refreshControl?.endRefreshing()
                        })
                    }])
                    
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
        
//        let accessoryButton = cell.detailDisclosureButton
//        cell.accessoryView = accessoryButton
//        let tapRecognizer = UIGestureRecognizer(target: cell.accessoryView, action: "tableView:accessoryButtonTappedForRowWithIndexPath:")
//        cell.accessoryView?.addGestureRecognizer(tapRecognizer)
        
//        /* If button selected to open URL, open it */
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "openURLForRow")
//        tapRecognizer.numberOfTouches() = 1
//        cell.detailDisclosureButton.addGestureRecognizer(tapRecognizer)
        
        return cell
    }

    func didTapAccessoryUpInside(tableView: UITableView, cellForRowAtIndexPath: NSIndexPath) {
        print("Cool")
    }
}

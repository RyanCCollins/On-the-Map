//
//  ExtendsUIViewController.swift
//  On The Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit

extension UIViewController {
    
    func loginCompletedSuccessfully() {
        /* Code for parse here */
    }
    
    func refreshDataFromParse(){
       
        
    }
    
    
    
    func reloadData() {
        /* reload Parse data */
        ParseClient.sharedInstance().studentData = nil
    }
    
    func performLogoutSegue() {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("logoutSegue", sender: self)
        })
    }
    
    func enterLocationData(){
        
    }
    
    /* Alert before logging out, then logout */
    func userWillLogout(sender: AnyObject) {
        UdaciousClient.sharedInstance().logoutOfSession({success, error in
            if success {
                
                if FBSDKAccessToken.currentAccessToken() != nil {
                    let facebookLogin = FBSDKLoginManager()
                    facebookLogin.logOut()
                    
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                
                let logoutAction = UIAlertAction(title: "Logout", style: .Destructive) {Void in
                    
                    self.logoutOfSession()
                    return
                }
                
                self.alertUserWithWithActions("Logout?", message: "Are you sure you want to logout?", actions: [cancelAction, logoutAction])
                
            } else {
                
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                self.alertUserWithWithActions("Failed to logout", message: "Sorry, but we were unable to log you out.", actions: [action])
            }
        })
    }
    
    func logoutOfSession(){
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("logoutSegue", sender: self)
        })
    }
    
    @IBAction func didTapRefreshTouchUpInside(sender: AnyObject) {
        reloadData()
        if let parent = sender.parentViewController as? MapViewController {

            parent.refreshViewForDataUpdate()

            
        } else if let parent = sender.parentViewController as? ListTableTableViewController {

            parent.refreshViewForDataUpdate()

        }
    }
    
    /* Helper function to show alerts to user */
    func alertUserWithWithActions(title: String, message: String, actions: [UIAlertAction]) {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            for action in actions {
                ac.addAction(action)
                
            }
            
            self.presentViewController(ac, animated: true, completion: nil)
            
        })
    }
    
    /* Helper function: construct an NSLocalizedError from an error string */
    func errorFromString(string: String) -> NSError? {
        
        return NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(string)"])
        
    }
}

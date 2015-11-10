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
    
    func reloadData() {
        /* reload Parse data */
    }

    func logOutOfApplication() {
        
    }
    
    func didLoginSuccessfully() {
        dispatch_async(dispatch_get_main_queue(), {
            let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabBarController")
            self.presentViewController(tabBarController!, animated: true, completion: nil)
        })
        
        UdaciousClient.sharedInstance().getUserData(nil)  {success, error in
            if success {
                
            } else {
                
            }
        }
    }
    
    func userDidLogout(sender: AnyObject) {
        
    }
}

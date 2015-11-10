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

    
    func enterLocationData(){
        
    }
    
    func userDidLogout(sender: AnyObject) {
        
    }
    
    /* Helper function: construct an NSLocalizedError from an error string */
    class func errorFromString(string: String) -> NSError? {
        
        return NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(string)"])
        
    }
}

//
//  LoginViewHelperExtensions.swift
//  On The Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

//#-MARK: Extension for the UITextFieldDelegate and Keyboard Notification Methods for LoginViewController
extension LoginViewController {
    
    
    func didLoginSuccessfully() {
        
        /* To do - clean up view */
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.indicatorLabel.alpha = 1.0
            self.indicatorLabel.startAnimating()
            let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
            self.presentViewController(tabBarController, animated: true, completion: {
                
                self.indicatorLabel.stopAnimating()
                self.indicatorLabel.hidden = true
                
                
            })
        })
        
//        UdaciousClient.sharedInstance().getUserData([:]) {success, error in
//            if success {
//                print("success")
//            } else {
//                
//            }
//        }
    }
    
    
    /* Mark Touch ID: */
    enum LAError : Int {
        case AuthenticationFailed
        case UserCancel
        case UserFallback
        case SystemCancel
        case PasscodeNotSet
        case TouchIDNotAvailable
        case TouchIDNotEnrolled
    }
    
}
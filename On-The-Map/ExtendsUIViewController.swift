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
import SwiftSpinner

extension UIViewController {

    
    func reloadData() {
        /* reload Parse data */
        ParseClient.sharedInstance().studentData = nil
    }
    
    /* Create an alert controller with an array of callback handlers   */
    func alertController(withTitles titles: [String], message: String, callbackHandler: [((UIAlertAction)->Void)?]) {
        
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .ActionSheet)
        
        for title in titles.enumerate() {
            
            if let callbackHandler = callbackHandler[title.index] {
            
                let action = UIAlertAction(title: title.element, style: .Default, handler: callbackHandler)
                
                alertController.addAction(action)
            
            } else {
                
                let action = UIAlertAction(title: title.element, style: .Default, handler: nil)
                
                alertController.addAction(action)
                
            }
            
            
            
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    /* Helper function: construct an NSLocalizedError from an error string */
    func errorFromString(string: String) -> NSError? {
        
        return NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(string)"])
        
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    /* Configure and deselect text fields when return is pressed */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    /* Suscribe the view controller to the UIKeyboardWillShowNotification */
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /* Unsubscribe the view controller to the UIKeyboardWillShowNotification */
    func unsubsribeToKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    /* Hide keyboard when view is tapped */
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        /* slide the view up when keyboard appears, using notifications */
        if view.frame.origin.y == 0.0 {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    /* Reset view origin when keyboard hides */
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    /* Get the height of the keyboard from the user info dictionary */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

    
    @IBAction func didTapLogoutUpInside(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        UdaciousClient.sharedInstance().logoutOfSession({success, error in
            if success {
                
                if FBSDKAccessToken.currentAccessToken() != nil {
                    let facebookLogin = FBSDKLoginManager()
                    facebookLogin.logOut()
                    
                }
                
                dispatch_async(GlobalMainQueue, {
                    
                    self.alertController(withTitles: ["Cancel", "Logout"], message: "Are you sure that you want to logout?", callbackHandler: [nil, {Void in
                            appDelegate.userAuthenticated = false
                            self.performSegueWithIdentifier("logoutSegue", sender: self)
                    }])
                    
                })
                
            } else {
                
                dispatch_async(GlobalMainQueue, {
                    
                    self.alertController(withTitles: ["OK", "Try Again"], message: GlobalErrors.LogOut.localizedDescription, callbackHandler: [nil, {Void in
                            self.didTapLogoutUpInside(self)
                    }])
                    
                })
            }
        })
    }
}

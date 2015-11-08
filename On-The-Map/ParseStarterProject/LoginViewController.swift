//
//  LoginViewController.swift
//  On-The-Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var didTapLoginButtonUpInside: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var faceBookLoginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Configure and add the facebook login button */
        let faceBookLoginButton = FBSDKLoginButton()
        faceBookLoginButton.delegate = self
        faceBookLoginButton.readPermissions = [FBReadPermissions.PublicProfile, FBReadPermissions.Email, FBReadPermissions.UserFriends]
        
        
        faceBookLoginView.addSubview(faceBookLoginButton)
    }
    override func viewWillAppear(animated: Bool) {
        subscribeToKeyboardNotification()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        unsubsribeToKeyboardNotification()
    }
    @IBAction func didTapLoginTouchUpInside(sender: AnyObject) {
        
        guard verifyUserCredentials(usernameTextField.text, password: passwordTextField.text) else {
            return
        }
        
        let parameters = [UdaciousClient.ParameterKeys.Udacity :
            [UdaciousClient.ParameterKeys.Username : usernameTextField.text!,
            UdaciousClient.ParameterKeys.Password : passwordTextField.text!
        ]]
        
        UdaciousClient.sharedInstance().authenticateWithViewController(parameters) { success, error in
            
        }
    }
    
    /* Verify that a proper username and password has been provided */
    func verifyUserCredentials(username: String?, password: String?) -> Bool {
        let alertController = UIAlertController()
        if let password = password {
            if let username = username {
                if username.containsString("@") && username.containsString(".") {
                    return true
                } else {
                    /* Todo: alert user */
                }
            } else {
                /* Todo: alert user */
            }
        } else {
            /* Todo: alert user */
        }
        return false
    }
    
    /* Facebook login delegate methods */
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            /* get a token from facebook */
            
            if let token = result.token.tokenString {
                
                let parameters = [UdaciousClient.ParameterKeys.Facebook : [UdaciousClient.ParameterKeys.AccessToken : token]]
                
                UdaciousClient.sharedInstance().authenticateWithViewController(parameters) { success, error in
                    /* if successful, complete login, otherwise update debug message */
                    if success {
                        self.completeLogin()
                    } else {
                        self.displayDebugMessage("An error occured while logging into facebook.  Please try again or login through Udacity")
                    }
                }
            } else {
                self.displayDebugMessage("An error occured while logging in with Facebook, please try again or login through Udacity")
            }
        } else {
            let debugString = "An error occured while logging in with Facebook, please try again or login through Udacity"
            print("\(debugString) \(error)")
            displayDebugMessage(debugString)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        displayDebugMessage("Logged out of Facebook")
    }
    
    /* Async update helper functions */
    func displayDebugMessage(debugString: String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.debugLabel.text = debugString
        })
    }
    
    func completeLogin() {
        displayDebugMessage("success!")
    }
}

struct FBReadPermissions {
    static let PublicProfile = "public_profile"
    static let Email = "email"
    static let UserFriends = "user_friends"
}
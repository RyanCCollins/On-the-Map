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

    @IBOutlet weak var emailTextField: UITextField!
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
    
    /* Facebook login delegate methods */
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            /* get a token from facebook */
            
            if let token = result.token.tokenString {
                
                let FBLoginToken = [ UdaciousClient.ParameterKeys.AccessToken : token ]
                
                UdaciousClient.sharedInstance().authenticateWithViewController(FBLoginToken, parameterKeys: UdaciousClient.ParameterKeys.Facebook) { success, errorString in
                    /* if successful, complete login, otherwise update debug message */
                    if success {
                        self.completeLogin()
                    } else {
                        self.displayDebugMessage(errorString!)
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
        
    }
}

struct FBReadPermissions {
    static let PublicProfile = "public_profile"
    static let Email = "email"
    static let UserFriends = "user_friends"
}
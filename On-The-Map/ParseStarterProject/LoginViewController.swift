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
import ChameleonFramework
import SwiftSpinner
import FlatUIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: KaedeTextField!
    @IBOutlet weak var passwordTextField: KaedeTextField!

    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var onePasswordContainer: UIView!
    @IBOutlet weak var signUpButton: UIButton!

    @IBOutlet weak var onepasswordButton: UIButton!
    @IBOutlet weak var oneTimePasswordTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Configure and add the facebook login button */
        let faceBookLoginButton = FBSDKLoginButton()
        faceBookLoginButton.delegate = self
        faceBookLoginButton.readPermissions = [FBReadPermissions.PublicProfile, FBReadPermissions.Email, FBReadPermissions.UserFriends]
        
        /* Hide 1Password Button if not installed */
//        self.onepasswordButton.hidden = (false == OnePasswordExtension.sharedExtension().isAppExtensionAvailable())   

        
        /* Configure log in buttons */
        
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        
        self.setStatusBarStyle(UIStatusBarStyleContrast)
        
        setUpColorScheme()
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        /* Add facebook button */
        loginButton.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 40).active = true
        loginButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -40).active = true
        loginButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -16).active = true
        loginButton.heightAnchor.constraintEqualToConstant(45).active = true
        
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubsribeToKeyboardNotification()
    }
    
    
    @IBAction func didTapLoginTouchUpInside(sender: AnyObject) {
        
            /* if you cannot verify the users credentials, show an error message. */
            guard self.verifyUserCredentials(self.usernameTextField.text, password: self.passwordTextField.text) else {
                
                /* Show alert */
                alertController(withTitles: ["Ok"], message: GlobalErrors.BadCredentials.localizedDescription, callbackHandler: [nil])
                
                return
            }
        
        let parameters = [UdaciousClient.ParameterKeys.Udacity :
            [UdaciousClient.ParameterKeys.Username : self.usernameTextField.text!,
                UdaciousClient.ParameterKeys.Password : self.passwordTextField.text!
            ]]
        authenticateUdacitySession(parameters)
        
        /* show log in message */
        dispatch_async(GlobalMainQueue, {
            SwiftSpinner.show("Logging in")
            SwiftSpinner.showWithDelay(12.0, title: "Taking longer than expected.  Just a moment.")
        })
        
    }
    
    func authenticateUdacitySession(parameters : [String : AnyObject]) {
        
        /* aunthenticate then get user information  in didLoginSuccessfully */
        dispatch_async(GlobalUtilityQueue, {
            
            UdaciousClient.sharedInstance().authenticateWithViewController(parameters) { success, error in
                if success {
                    
                    dispatch_async(GlobalMainQueue, {
                        
                        SwiftSpinner.show("Authenticated")
                        self.didLoginSuccessfully()
                    })
                    
                } else {
                    
                    dispatch_async(GlobalMainQueue, {
                        SwiftSpinner.hide({
                            self.alertController(withTitles: ["Ok", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, { Void in
                                self.didTapLoginTouchUpInside(self)
                                }])
                            
                        })
                        
                    })
                    
                }
            }
        })
        
    }
    
    /* If logged in successfully, get the user's data */
    func didLoginSuccessfully() {
        
        UdaciousClient.sharedInstance().getUserData() {success, error in
            if success {
                
                /* Set user as authenticate */
                self.appDelegate.userAuthenticated = true
                
                dispatch_async(GlobalMainQueue, {
                    let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
                    self.presentViewController(tabBarController, animated: true, completion: {
                        
                        /* Hide activity Indicator*/
                        SwiftSpinner.hide()
                    })
                    
                })
                
                
            } else {
                dispatch_async(GlobalMainQueue, {
                    /* Present an alert controller with an appropriate message */
                    self.alertController(withTitles: ["Ok", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in
                        self.didTapLoginTouchUpInside(self)
                    }])
                    
                })
                
                
            }
            
        }
    }

    
    /* Verify that a proper username and password has been provided */
    func verifyUserCredentials(username: String?, password: String?) -> Bool {
        
        if password != nil && username!.containsString("@") && username!.containsString(".") {
            return true
         
        }
        
        return false
    }
    
    
    /* Facebook login delegate methods */
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil {
            /* get a token from facebook */
            
            SwiftSpinner.show("Logging you in through Facebook. Just a moment")
            
            if let token = result.token.tokenString {
                
                let parameters = [UdaciousClient.ParameterKeys.Facebook : [UdaciousClient.ParameterKeys.AccessToken : token]]
                
                authenticateUdacitySession(parameters)
            }
        }
    }

    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        
        
    }
    
    
    /* 1Password methods */
    @IBAction func findLoginFrom1Password(sender:AnyObject) -> Void {
        OnePasswordExtension.sharedExtension().findLoginForURLString("https://www.udacity.com", forViewController: self, sender: sender, completion: { (loginDictionary, error) -> Void in
            if loginDictionary == nil {
                if error!.code != Int(AppExtensionErrorCodeCancelledByUser) {
                    
                    print("Error invoking 1Password App Extension for find login: \(error)")
                }
                return
            }
            
            self.usernameTextField.text = loginDictionary?[AppExtensionUsernameKey] as? String
            self.passwordTextField.text = loginDictionary?[AppExtensionPasswordKey] as? String
            
            if let generatedOneTimePassword = loginDictionary?[AppExtensionTOTPKey] as? String {
                self.oneTimePasswordTextField.hidden = false
                self.oneTimePasswordTextField.text = generatedOneTimePassword
                
                // Important: It is recommended that you submit the OTP/TOTP to your validation server as soon as you receive it, otherwise it may expire.
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
//                    self.performSegueWithIdentifier("showThankYouViewController", sender: self)
                })
            }
            
        })
    }
    
    
    /* MARK: Did tap signup, direct to udacity page */
    @IBAction func didTapSignUpTouchUpInside(sender: AnyObject) {
        let url = NSURL(string : "https://www.udacity.com/account/auth#!/signin")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    /* setup colors of main login buttons */
    func setUpColorScheme(){
        /* Set colors of buttons */
        let colorScheme = appDelegate.colorScheme
        
        view.backgroundColor = colorScheme[1] as? UIColor
        
        usernameTextField.backgroundColor = colorScheme[2] as? UIColor
        
        passwordTextField.backgroundColor = colorScheme[2] as? UIColor
        
        usernameTextField.foregroundColor = colorScheme[1] as? UIColor
        
        passwordTextField.foregroundColor = colorScheme[1] as? UIColor
        
        
        onePasswordContainer.backgroundColor = colorScheme[1] as? UIColor
        
        loginButton.backgroundColor = colorScheme[3] as? UIColor
        signUpButton.backgroundColor = colorScheme[3] as? UIColor
        
        loginLabel.textColor = colorScheme[2] as? UIColor
        headerLabel.textColor = colorScheme[2] as? UIColor
        
        onepasswordButton.backgroundColor = UIColor.clearColor()
    }

}


/* Defines FB Read Permissions */
struct FBReadPermissions {
    static let PublicProfile = "public_profile"
    static let Email = "email"
    static let UserFriends = "user_friends"
}


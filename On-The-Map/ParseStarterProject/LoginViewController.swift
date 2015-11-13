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
    @IBOutlet weak var faceBookLoginView: UIView!
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
        /* Add facebook button */
        faceBookLoginButton.center = view.center
        
        faceBookLoginView.addSubview(faceBookLoginButton)
        
        
        /* Configure log in buttons */
        
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        
        self.setStatusBarStyle(UIStatusBarStyleContrast)
        
        setUpColorScheme()
        
        
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
        
        /* run data update on background thread */
        
            /* if you cannot verify the users credentials, show an error message. */
            guard self.verifyUserCredentials(self.usernameTextField.text, password: self.passwordTextField.text) else {
                
                /* Show alert */
                SwiftSpinner.show("Please enter a valid email address and password").addTapHandler ({
                    SwiftSpinner.hide()
                    }, subtitle: "Tap to dismiss")
                
                return
            }
        
        /* show log in message */
        dispatch_async(dispatch_get_main_queue(), {
            SwiftSpinner.show("Logging in")
        })
        
        /* aunthenticate then get user information  in didLoginSuccessfully */
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            
            let parameters = [UdaciousClient.ParameterKeys.Udacity :
                [UdaciousClient.ParameterKeys.Username : self.usernameTextField.text!,
                    UdaciousClient.ParameterKeys.Password : self.passwordTextField.text!
                ]]
            
            UdaciousClient.sharedInstance().authenticateWithViewController(parameters) { success, error in
                if success {
                    
                    self.didLoginSuccessfully()
                    
                } else {
                    
                    SwiftSpinner.show("Sorry, but we could not authenticate your Udacity account.").addTapHandler ({
                        SwiftSpinner.hide()
                    }, subtitle: "Please try again.")
                    
                }
            }
        })
    }
    
    func didLoginSuccessfully() {
        
        /* To do - clean up view */
        UdaciousClient.sharedInstance().getUserData() {success, error in
            if success {
                
                /* Set user as authenticate */
                self.appDelegate.userAuthenticated = true
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    
                    
                    let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
                    self.presentViewController(tabBarController, animated: true, completion: {
                        
                        /* Hide activity Indicator*/
                        SwiftSpinner.hide()
                        
                    })
                })
            } else {
                
                SwiftSpinner.show("Sorry, but we were unable to obtain your user information from Udacity.").addTapHandler({
                    SwiftSpinner.hide()
                    }, subtitle: "Tap to dismiss")
                
            }
            
            
            
        }
    }

    
    /* Verify that a proper username and password has been provided */
    func verifyUserCredentials(username: String?, password: String?) -> Bool {
        
        if password != nil && username!.containsString("@") && username!.containsString(".") {
            return true
         
        }
        
        SwiftSpinner.show("Please enter a valid username and password").addTapHandler ({
            SwiftSpinner.hide()
            }, subtitle: "Tap to dismiss")
        return false
    }
    
    /* Facebook login delegate methods */
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil {
            /* get a token from facebook */
            
            SwiftSpinner.show("Logging you in through Facebook. Just a moment")
            
            if let token = result.token.tokenString {
                
                let parameters = [UdaciousClient.ParameterKeys.Facebook : [UdaciousClient.ParameterKeys.AccessToken : token]]
                
                UdaciousClient.sharedInstance().authenticateWithViewController(parameters) { success, error in
                    /* if successful, complete login, otherwise update debug message */
                    if success {
                        
                        SwiftSpinner.hide()
                        
                        self.didLoginSuccessfully()
                    
                    } else {
                        
                        SwiftSpinner.show("Could not log you in using facebook").addTapHandler({
                                SwiftSpinner.hide()
                            }, subtitle: "Tap to dismiss")
                        
                    }
                }
            } else {
                
                SwiftSpinner.show("Could not log you in using facebook").addTapHandler({
                    SwiftSpinner.hide()
                    }, subtitle: "Tap to dismiss")
                
                
            }
        } else {

            SwiftSpinner.show("Could not log you in using facebook").addTapHandler({
                SwiftSpinner.hide()
                }, subtitle: "Tap to dismiss")
            

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


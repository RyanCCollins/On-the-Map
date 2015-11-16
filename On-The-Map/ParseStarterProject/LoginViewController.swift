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
        
        /* Hide 1Password Button if not installed -- NOTE: DISABLED FOR REVIEWER TO SHOW THAT IT'S THERE */
        /* self.onepasswordButton.hidden = (false == OnePasswordExtension.sharedExtension().isAppExtensionAvailable()) */

        
        /* Configure log in buttons */
        
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        
        self.setStatusBarStyle(UIStatusBarStyleContrast)
        
        setUpColorScheme()
        
        /* Add facebook button and configure */
        let facebookLoginButton = FBSDKLoginButton()
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = [FBReadPermissions.PublicProfile, FBReadPermissions.Email, FBReadPermissions.UserFriends]
        facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(facebookLoginButton)

        /* Add constraints for FB Login Button */
        facebookLoginButton.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 40).active = true
        facebookLoginButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -40).active = true
        facebookLoginButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -16).active = true
        facebookLoginButton.heightAnchor.constraintEqualToConstant(45).active = true
        
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
        
        /* Safeguard from having a facebook login token while logging in through udacity */
        if FBSDKAccessToken.currentAccessToken() != nil {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            FBSDKAccessToken.setCurrentAccessToken(nil)
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubsribeToKeyboardNotification()
    }
    
    
    @IBAction func didTapLoginTouchUpInside(sender: AnyObject) {
        
            /* If you cannot verify the users credentials, show an error message. */
            guard self.verifyUserCredentials(self.usernameTextField.text, password: self.passwordTextField.text) else {

                alertController(withTitles: ["Ok"], message: GlobalErrors.BadCredentials.localizedDescription, callbackHandler: [nil])
                
                return
            }
        
        /* Build a dictionary containing login parameters for Udacity login */
        let parameters = [UdaciousClient.ParameterKeys.Udacity :
            [UdaciousClient.ParameterKeys.Username : self.usernameTextField.text!,
                UdaciousClient.ParameterKeys.Password : self.passwordTextField.text!
            ]]
        
        
        /* Authenticate the session through Udacity */
        authenticateUdacitySession(parameters)
        
        /* Show log in message */
        dispatch_async(GlobalMainQueue, {
            SwiftSpinner.show("Logging in")
            SwiftSpinner.showWithDelay(10.0, title: "Just a moment.")
        })
        
    }
    
    /* Authenticate the Udacity session either through facebook or with Udacity credentials */
    func authenticateUdacitySession(parameters : [String : AnyObject]) {
        
        /* Aunthenticate then get user information  in didLoginSuccessfully */
        dispatch_async(GlobalUtilityQueue, {
            
            UdaciousClient.sharedInstance().authenticateWithViewController(parameters) { success, error in
                if success {
                    
                    /* Show that you have authenticated and finish login */
                    dispatch_async(GlobalMainQueue, {
                        
                        SwiftSpinner.show("Authenticated")
                        self.didLoginSuccessfully()
                    })
                    
                } else {
                    
                    /* Present an alert controller with an appropriate message */
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
                
                /* Present an alert controller with an appropriate message */
                dispatch_async(GlobalMainQueue, {
                    
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
            
            SwiftSpinner.show("Logging you in through Facebook. Just a moment.")
            
            /* Get a token from facebook */
            if let token = result.token.tokenString {
                
                let parameters = [UdaciousClient.ParameterKeys.Facebook : [UdaciousClient.ParameterKeys.AccessToken : token]]
                
                authenticateUdacitySession(parameters)
            }
        }
    }

    /* Logout button shold not usually show, but in case it does */
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            let facebookLogin = FBSDKLoginManager()
            facebookLogin.logOut()
        }
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
            }
            
        })
    }
    
    
    /* MARK: Did tap signup, direct to udacity page */
    @IBAction func didTapSignUpTouchUpInside(sender: AnyObject) {
        let url = NSURL(string : "https://www.udacity.com/account/auth#!/signin")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    /* Setup colors of main login buttons */
    func setUpColorScheme(){
        /* Set colors of buttons and other fields */
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


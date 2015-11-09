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


    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var faceBookLoginView: UIView!
    @IBOutlet weak var onepasswordButton: UIButton!
    @IBOutlet weak var oneTimePasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Configure and add the facebook login button */
        let faceBookLoginButton = FBSDKLoginButton()
        faceBookLoginButton.delegate = self
        faceBookLoginButton.readPermissions = [FBReadPermissions.PublicProfile, FBReadPermissions.Email, FBReadPermissions.UserFriends]
        
        /* Hide 1Password Button if not installed */
//        self.onepasswordButton.hidden = (false == OnePasswordExtension.sharedExtension().isAppExtensionAvailable())
        
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
        print(parameters)
        UdaciousClient.sharedInstance().authenticateWithViewController(parameters) { success, error in
            if success {
                print("success")
            } else {
                print(error)
            }
        }
    }
    
    @IBOutlet weak var didTapSignupButtonTouchUpInside: UIButton!
    /* Verify that a proper username and password has been provided */
    func verifyUserCredentials(username: String?, password: String?) -> Bool {
//        let alertController = UIAlertController()
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
                        print("success")
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
//        displayDebugMessage("success!")
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

    @IBAction func didTapSignUpTouchUpInside(sender: AnyObject) {
        let url = NSURL(string : "https://www.udacity.com/account/auth#!/signin")
        UIApplication.sharedApplication().openURL(url!)
    }
}

struct FBReadPermissions {
    static let PublicProfile = "public_profile"
    static let Email = "email"
    static let UserFriends = "user_friends"
}

extension LoginViewController {
    
}
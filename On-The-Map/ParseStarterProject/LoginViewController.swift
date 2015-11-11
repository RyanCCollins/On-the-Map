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

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var onePasswordContainer: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var faceBookLoginView: UIView!
    @IBOutlet weak var onepasswordButton: UIButton!
    @IBOutlet weak var oneTimePasswordTextField: UITextField!

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Configure and add the facebook login button */
        let faceBookLoginButton = FBSDKLoginButton()
        faceBookLoginButton.delegate = self
        faceBookLoginButton.readPermissions = [FBReadPermissions.PublicProfile, FBReadPermissions.Email, FBReadPermissions.UserFriends]
        
        /* Hide 1Password Button if not installed */
//        self.onepasswordButton.hidden = (false == OnePasswordExtension.sharedExtension().isAppExtensionAvailable())
        faceBookLoginView.addSubview(faceBookLoginButton)
        faceBookLoginButton.center = faceBookLoginView.center
//        faceBookLoginButton.frame = faceBookLoginView.frame
        print(faceBookLoginButton.center)
        print(faceBookLoginView.center)
        print(faceBookLoginButton.frame)
        
        /* Configure log in buttons */

        self.setStatusBarStyle(UIStatusBarStyleContrast)
        
        setUpColorScheme()
        
        
    }
    
    func setUpColorScheme(){
//        /* Set colors of buttons */
//        let colorScheme = appDelegate.colorScheme
//        loginButton.backgroundColor = colorScheme[1] as? UIColor
//        signUpButton.backgroundColor = UIColor.clearColor()
//        usernameTextField.backgroundColor = colorScheme[2] as? UIColor
//        passwordTextField.backgroundColor = colorScheme[2] as? UIColor
        onepasswordButton.backgroundColor = UIColor.clearColor()
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        
        subscribeToKeyboardNotification()
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        unsubsribeToKeyboardNotification()
    }
    @IBAction func didTapLoginTouchUpInside(sender: AnyObject) {
        
        
        SwiftSpinner.show("Logging in")
        
        /* run data update on background thread */
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            guard self.verifyUserCredentials(self.usernameTextField.text, password: self.passwordTextField.text) else {
                return
            }
            
            let parameters = [UdaciousClient.ParameterKeys.Udacity :
                [UdaciousClient.ParameterKeys.Username : self.usernameTextField.text!,
                    UdaciousClient.ParameterKeys.Password : self.passwordTextField.text!
                ]]
            
            UdaciousClient.sharedInstance().authenticateWithViewController(parameters) { success, error in
                if success {
                    
                    self.didLoginSuccessfully()
                    
                } else {
                    
                    self.displayDebugMessage("Sorry, but we could not log you in, please try again!")
                    
                }
            }
        })
    }

    
    /* Verify that a proper username and password has been provided */
    func verifyUserCredentials(username: String?, password: String?) -> Bool {
        
        if let password = password {
            
            if let username = username {
                
                if username.containsString("@") && username.containsString(".") {
                    
                    return true
                }
        
            }
        }
        displayDebugMessage("Sorry, but we couldn't log you in.  Please try again.")
        return false
    }
    
    /* Facebook login delegate methods */
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil {
            /* get a token from facebook */
            
            if let token = result.token.tokenString {
                
                let parameters = [UdaciousClient.ParameterKeys.Facebook : [UdaciousClient.ParameterKeys.AccessToken : token]]
                
                UdaciousClient.sharedInstance().authenticateWithViewController(parameters) { success, error in
                    /* if successful, complete login, otherwise update debug message */
                    if success {
                        print("success")
                        self.didLoginSuccessfully()
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
    
    
    func didLoginSuccessfully() {
        
        /* To do - clean up view */
        
        dispatch_async(dispatch_get_main_queue(), {
            
            
            let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
            self.presentViewController(tabBarController, animated: true, completion: {
                
                /* Hide activity Inidcatory */
                SwiftSpinner.hide()
                
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
    
    /*MARK: Touch ID */
    @IBAction func touchIDButtonTouch(sender: AnyObject) {
//        
//        let context = LAContext()
//        
//        var error: NSError?
//        
//        //check if passcode or touchID sensor exist and response nicely.
//        if !context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error){
//            
//            switch error!.code{
//            case LAError.TouchIDNotEnrolled.rawValue:
//                showAlertView("TouchID is not enrolled")
//            case LAError.PasscodeNotSet.rawValue:
//                showAlertView("A passcode has not been set")
//            default:
//                showAlertView("TouchID is not available")
//            }
//            
//            return
//        }
//        // in the first if, check if a username was saved and in the second if, check if there is a password associated with that account in the keychain.
//        if let name = NSUserDefaults.standardUserDefaults().stringForKey(OTMClient.JSONBodyKeys.Username){
//            if let password = SSKeychain.passwordForService("OnTheMap_Password_Service", account: name){
//                
//                //here hasconnectivity use reachablity class to look for internet connection.
//                if self.hasConnectivity(){
//                    startTouchIDOperation(name, password: String(password))
//                }
//            }
//            else{
//                showAlertView("No account info\nEnter username & password and hit login")
//            }
//        }
//        else{
//            showAlertView("No account info\nEnter username & password and hit login")
//        }
    }
    
    /* MARK: Did tap signup, direct to udacity page */
    @IBAction func didTapSignUpTouchUpInside(sender: AnyObject) {
        let url = NSURL(string : "https://www.udacity.com/account/auth#!/signin")
        UIApplication.sharedApplication().openURL(url!)
    }
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

struct FBReadPermissions {
    static let PublicProfile = "public_profile"
    static let Email = "email"
    static let UserFriends = "user_friends"
}

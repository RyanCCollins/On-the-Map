/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit

import Parse
import FBSDKCoreKit
import ChameleonFramework
import Fabric
import Crashlytics


// If you want to use any of the UI components, uncomment this line
// import ParseUI

// If you want to use Crash Reporting - uncomment this line
// import ParseCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var colorScheme: NSArray!
    var userAuthenticated: Bool!
    var facebookAuth = false

    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        
        /* Configure color */
        let color = UIColor.flatNavyBlueColorDark()
        let secondary = UIColor.flatBlueColorDark()

        colorScheme = NSArray(ofColorsWithColorScheme: .Analogous, usingColor: color, withFlatScheme: true)
        Chameleon.setGlobalThemeUsingPrimaryColor(secondary, withContentStyle: .Contrast)
        
        /* Set app and client IDs for Parse Push notifications. NOTE: Constant values are used for fetching and posting to Parse.  This is only used for PUSH notifications */
        Parse.setApplicationId("QsRf7t1UHL1PaFVPVk6lCV70dGao4Lqvre5zXKDL",
            clientKey: "o383Qm9g9ejRTSMjHcfiFhHdIVTmSC9rPkHnF9vf")
        
        PFUser.enableAutomaticUser()

        let defaultACL = PFACL();

        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)

        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)

        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.

            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        /* Fabric crashlytics initialization */
        Fabric.with([Crashlytics.self])
        
        
        /* Add notification types for ios 8+, keeping older options in case released for an earlier os */
            if #available(iOS 8.0, *) {
                let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
                let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
            } else {
                let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
                application.registerForRemoteNotificationTypes(types)
            }

        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }


    /* MARK: Push Notifications */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()

        PFPush.subscribeToChannelInBackground("global") { (succeeded: Bool, error: NSError?) in
            if succeeded {
                print("On the map successfully subscribed to push notifications on the broadcast channel.\n");
            } else {
                print("On the map failed to subscribe to push notifications on the broadcast channel with error = %@.\n", error)
            }
        }
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.\n")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@\n", error)
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }

    /* Handle background push notifications */
     func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        PFPush.handlePush(userInfo)
        
         if application.applicationState == UIApplicationState.Inactive {
             PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
         }
     }

    /* FBSDK Open URL method */
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
}

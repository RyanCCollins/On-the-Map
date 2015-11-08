//
//  UdacityConvenience.swift
//  On-The-Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

extension UdaciousClient {
    
    /* Work through the authorization chain using the convenience methods */
    func authenticateWithViewController(parameters: [String : AnyObject], completionHandler: (success: Bool, error: NSError?) -> Void){
        /* get the session id */
        
        getSession(parameters) { success, sessionID, userKey, error in
            if success {
                
                self.sessionID = sessionID
                self.userKey = userKey
                
                completionHandler(success: true, error: nil)
            } else {
                
                completionHandler(success: false, error: error)
            }
        }

    }
    
    /* 1. Get the Session ID for the user */
    func getSession(parameters: [String : AnyObject]?, completionHandler: (success: Bool, sessionID: String?, userKey: String?, error: NSError?) -> Void) {
        /* Check for success */
        
        
        taskForPOSTMethod(UdaciousClient.Methods.PostSession, parameters: parameters!) { JSONResult, error in
            if let error = error {
                
                completionHandler(success: false, sessionID: nil, userKey: nil, error: error)
            } else {
                /* Attempt to get the session ID */
                if let session = JSONResult.valueForKey(UdaciousClient.JSONResponseKeys.Session) {
                    
                    if let sessionID = session.valueForKey(UdaciousClient.JSONResponseKeys.SessionID) as? String {
                        
                        /* get the account and user from JSONResult */
                        if let account = JSONResult.valueForKey(UdaciousClient.JSONResponseKeys.Account) {
                    
                            let user = account.valueForKey(UdaciousClient.JSONResponseKeys.User) as! String
                    
                            completionHandler(success: true, sessionID: sessionID, userKey: user, error: nil)
                    
                        } else {
                            completionHandler(success: false, sessionID: nil, userKey: nil, error: UdaciousClient.errorFromString("Failed to parse the data in getSession.  No Account returned"))
                        }
                    } else {
                        completionHandler(success: false, sessionID: nil, userKey: nil, error: UdaciousClient.errorFromString("Failed to parse the data in getSession.  No session returned"))
                    }
                }
            }
        }
        
        
    }
    /* 2. Get the user's data */
    
    func getUserData(parameters: [String : AnyObject]?, completionHandler: (success: Bool, error: NSError?) -> Void) {
        /* make request and check for success */
        let parameters = [ String : AnyObject ]()
        taskForGETMethod(UdaciousClient.Methods.GetUserData, parameters: parameters) {success, error in
            
        }
    }
    
    /* 3. Logout (DELETE) the session */
    func logoutOfSession(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
    }
    
}

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
        
        getSession(parameters) { success, sessionID, IDKey, error in
            if success {
                
                self.sessionID = sessionID
                self.IDKey = IDKey
                
                completionHandler(success: true, error: nil)
            } else {
                
                completionHandler(success: false, error: error)
            }
        }

    }
    
    /* 1. Get the Session ID for the user */
    func getSession(parameters: [String : AnyObject]?, completionHandler: (success: Bool, sessionID: String?, userKey: String?, error: NSError?) -> Void) {
        /* Check for success */
        
        
        taskForPOSTMethod(UdaciousClient.Methods.Session, parameters: parameters!) { JSONResult, error in
            if let error = error {
                
                completionHandler(success: false, sessionID: nil, userKey: nil, error: error)
            } else {
                /* Attempt to get the session ID */
                if let session = JSONResult.valueForKey(UdaciousClient.JSONResponseKeys.Session) {

                    if let sessionID = session.valueForKey(UdaciousClient.JSONResponseKeys.SessionID) as? String {

                        /* get the account and user from JSONResult */
                        if let account = JSONResult.valueForKey(UdaciousClient.JSONResponseKeys.Account) {

                            if let key = account.valueForKey(UdaciousClient.JSONResponseKeys.IDKey) as? String {

                            completionHandler(success: true, sessionID: sessionID, userKey: key, error: nil)
                                
                            } else {
                                completionHandler(success: false, sessionID: sessionID, userKey: nil, error: UdaciousClient.errorFromString("Failed to parse the key data in  getSession"))
                            }
  
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
        /* Make request and check for success */
        let parameters = [ String : AnyObject ]()
        
        let method = UdaciousClient.substituteKeyInMethod(UdaciousClient.Methods.GetUserData, key: "{id}", value: IDKey!)
        
        taskForGETMethod(method!, parameters: parameters) {JSONResult, error in
            
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                
                /* If user data found, parse the results */
                if let result = JSONResult.valueForKey(UdaciousClient.JSONResponseKeys.User) {
                    
                    if let firstName = result.valueForKey(UdaciousClient.JSONResponseKeys.FirstName) as? String {
                        self.firstName = firstName
                        if let lastName = result.valueForKey(UdaciousClient.JSONResponseKeys.LastName) as? String{
                            self.lastName = lastName
                            /* Return with completion handler */
                            completionHandler(success: true, error: nil)
                        }
                        
                    }
                    
                } else {
                    /* return failure if JSON data not properly parsed */
                    completionHandler(success: false, error: UdaciousClient.errorFromString("Failed to parse JSON Data into User data in getUserData"))
                
                }
                
            }
            
        }
    }
    
    /* 3. Logout (DELETE) the session */
    func logoutOfSession(completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* call task for delete method to log user out */
        taskForDELETEMethod(Methods.Session) { result, error in
            
            if let error = error {
                
                completionHandler(success: false, error: UdaciousClient.errorFromString("Error returned for logoutOfSession. Error: \(error)"))
            
            } else {
                
                completionHandler(success: true, error: nil)
                
            }
        }
    }
}

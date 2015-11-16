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
                print(IDKey)
                completionHandler(success: true, error: nil)
            } else {
                
                completionHandler(success: false, error: error)
            }
        }

    }
    
    /* Get the Session ID for the user */
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
                        if let account = JSONResult[UdaciousClient.JSONResponseKeys.Account]  {

                            if let IDKey = account![UdaciousClient.JSONResponseKeys.IDKey] as? String {

                            completionHandler(success: true, sessionID: sessionID, userKey: IDKey, error: nil)
                                
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    /* Get the user's data */
    func getUserData(completionHandler: (success: Bool, error: NSError?) -> Void) {
        /* Make request and check for success */

        
        guard let IDKey = IDKey else {
            
            completionHandler(success: false, error: GlobalErrors.GenericError)
            return
        }

        let method = UdaciousClient.substituteKeyInMethod(UdaciousClient.Methods.GetUserData, key: "id", value: IDKey)

        taskForGETMethod(method!, parameters: [:]) {JSONResult, error in
            
            if error != nil {
                print("taskForGetMethod: \(error)")
                completionHandler(success: false, error: error)
                
            } else {
                
                /* If user data found, parse the results */
                if let result = JSONResult[UdaciousClient.JSONResponseKeys.User] {

                    if let firstName = result![UdaciousClient.JSONResponseKeys.FirstName] as? String {
                        self.firstName = firstName
                        
                        if let lastName = result![UdaciousClient.JSONResponseKeys.LastName] as? String{
                            self.lastName = lastName

                            /* Return with completion handler */
                            completionHandler(success: true, error: nil)

                        }
                        
                    }
                    
                }
                
            }
            
        }
    }
    
    /* 3. Logout (DELETE) the session */
    func logoutOfSession(completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* call task for delete method to log user out */
        taskForDELETEMethod(Methods.Session) { result, error in
            
            if let error = error {
                
                completionHandler(success: false, error: GlobalErrors.LogoutError)
            
            } else {
                
                completionHandler(success: true, error: nil)
                
            }
        }
    }
}

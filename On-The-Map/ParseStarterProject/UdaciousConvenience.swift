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
    func authenticateWithViewController(credentials: [String : AnyObject], parameters: [String : AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void){
        /* get the session id */
        getSession(credentials, parameters: parameters) { success, sessionID, userKey errorString in
            if success {
                
                self.sessionID = sessionID
                self.userKey = userKey
                
                completionHandler
            } else {
                
            }
        })

    }
    
    /* 1. Get the Session ID for the user */
    func getSession(credentials: [String : AnyObject], parameters: [String : AnyObject], completionHandler: (success: Bool, sessionID: String?, userKey: String?, errorString: String?) -> Void) {
        // -Todo: Get session id
        let JSONBody = [UdaciousClient.ParameterKeys. ]
    }
    /* 2. Get the user's data */
    
    func getUserData(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
    }
    
    /* 3. Logout (DELETE) the session */
    func logoutOfSession(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
    }
    
}

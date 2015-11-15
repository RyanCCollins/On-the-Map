//
//  UdaciousConstants.swift
//  On-The-Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import Foundation
/*This file is an extension of the UdacityClient class
and stores constancts that are used to connect to the Udacity API */
extension UdaciousClient {
    /* ID for Facebook */
    
    struct Constants {
        static let FacebookAppID = "365362206864879"
        
        static let BaseURLSecure = "https://www.udacity.com/api/"
    }
    
    
    struct Methods {
        static let Session = "session"
        static let GetUserData = "users/{id}"
    }
    
    /* Parameter keys for the Udacity API and Facebook API */
    struct ParameterKeys {
        
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let Facebook = "facebook_mobile"
        static let AccessToken = "access_token"
    }
    
    struct URLKeys {
        static let id = "id"
    }
    
    struct JSONResponseKeys {
        static let Session = "session"
        static let SessionID = "id"
        static let Account = "account"
        static let User = "user"
        static let FirstName = "nickname"
        static let LastName = "last_name"
        static let IDKey = "key"
    }
    
    enum HTTPRequest {
        static let GET = "GET"
        static let POST = "POST"
        static let DELETE = "DELETE"
    }
    
    struct Errors : ErrorType {
        static let Network = NSError(domain: "UdaciousClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occured while connecting to the network."])
        static let JSONSerialization =  NSError(domain: "UdaciousClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occured when sending data to the network."])
        static let Status =  NSError(domain: "UdaciousClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "An status error occured while connecting to the network."])
        static let Parse =  NSError(domain: "UdaciousClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occured while getting data from the network."])
        static let Auth =  NSError(domain: "UdaciousClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unable to log you in due to authentication.  Make sure your credentials are correct."])
    }
    struct Alerts {
        let okAlert = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        
    }
    
}

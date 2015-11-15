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
        
        static let JSONSerialization =  NSError(domain: "UdaciousClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occured when sending data to the network."])
        static let Parse =  NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occured while getting data from the network."])
        
        struct Status {
            static let Auth401 =  NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "The network returned an invalid response due to invalid credentials.  Please try again."])
            static let InvalidResponse = NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unable to log you in due to an invalid response from the server.  Please try again."])
            static let Network = NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not connect to the network.  Please try again."])
        }
    }

}

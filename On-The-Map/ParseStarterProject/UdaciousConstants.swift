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
        static let PostSession = "session"
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
        static let Key = "key"
    }
    
    enum HTTPRequest {
        static let GET = "GET"
        static let POST = "POST"
        static let DELETE = "DELETE"
    }
    
    struct JSONBodyKeys {
        
    }
}

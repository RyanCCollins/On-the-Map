//
//  ParseConstants.swift
//  On The Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

extension ParseClient {
    struct Constants {
        static let baseURLSecure = "https://api.parse.com/1/classes/"
        
        static let api_key = ""
        static let app_id = ""
    }
    
    struct Methods {
        static let StudentLocations = "StudentLocation"
    }
    
    struct ParameterKeys {
        static let limit = "limit"
        static let Skip = "skip" /* Number to paginate through results */
        static let Order = "order" /* Comma delimeted list of key names that specify default sort order of results */
        
    }
    
    struct JSONResponseKeys {
        
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let MediaURL = "mediaURL"
        static let Results = "results"
        static let Error = "error"
        static let Status = "status"
        static let CreatedAt = "createdAt"
        static let UpdateAt = "updatedAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let ACL = "ACL" /* Permissions (Access Command List) */
    }
    
    enum HTTPRequest {
        static let GET = "GET"
        static let POST = "POST"
        static let DELETE = "DELETE"
    }
}

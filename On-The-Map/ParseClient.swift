//
//  ParseClient.swift
//  On The Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
    struct Constants {
        static let baseURLSecure = "https://api.parse.com/1/classes/"
        
        static let api_key = ""
        static let app_id = ""
    }
    
    struct Methods {
        static let StudentLocations = "StudentLocation"
    }
    
    struct JSONResponseKeys {
        
        static let ObjectID = "objectId"
        static let MediaURL = "mediaURL"
        static let UniqueKey: String = "uniqueKey"
        static let Results: String = "results"
        static let Error: String = "error"
        static let UpdateAt: String = "updatedAt"
        
    }
    
    struct AccountKeys {
        static let FirstName = "firstName"
        static let LastName = "lastName"
        
    }
    struct MapKeys {
        static let MapString = "mapString"
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
}

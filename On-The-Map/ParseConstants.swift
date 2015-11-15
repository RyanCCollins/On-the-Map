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
        
        static let api_key = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let app_id = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    }
    
    struct Methods {
        static let StudentLocations = "StudentLocation"
        static let Where = "?where"
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
        static let UpdateTime = "updatedAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let GEODescriptor = "mapString"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let ACL = "ACL" /* Permissions (Access Command List) */
    }
    
    enum HTTPRequest {
        static let GET = "GET"
        static let POST = "POST"
        static let PUT = "PUT"
        static let DELETE = "DELETE"
    }
    
    struct Errors {
        static let ParseError = "Failed to Parse Data"
        static let PostError = "Failed to Post Data"
        static let GetError = "Failed to"
        
    }
}

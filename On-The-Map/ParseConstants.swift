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

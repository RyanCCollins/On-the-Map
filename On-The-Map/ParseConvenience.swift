//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

extension ParseClient {
    
    
    func getDataFromParse(completionHandler: (success: Bool, data: [StudentLocationData]?, error: NSError?)->Void) {
        taskForGETMethod(Methods.StudentLocations){ JSONResult, error in
            if let error = error {
                
                completionHandler(success: false, data: nil, error: error)
                
            } else {
                
                /* If results are returned and we are able to parse the data, return it as an array of studentData */
                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    
                    let studentData = StudentLocationData.generateLocationDataFromResults(results)
                        
                        self.studentData = studentData
                        
                        completionHandler(success: true, data: self.studentData, error: nil)
                }
                
            }
        }
    }
    
    func postDataToParse(locationParameters: [String : AnyObject], completionHandler: (success: Bool, error: NSError?) -> Void) {
        taskForPOSTMethod(Methods.StudentLocations, JSONBody: locationParameters) { result, error in
            
            if let error = error {
                
                completionHandler(success: false, error: error)
                
            } else {
                
                /* If we receive a response with an object ID, then we return it */
                if let _ = result[JSONResponseKeys.ObjectID] as? String {
                    
                    completionHandler(success: true, error: nil)
                    
                } else {
                    
                    completionHandler(success: false, error: ParseClient.errorFromString("Could not post data in postDataToParse"))
                    
                }
                
            }
            
        }
    }
    
    /* Helper function, creates JSON Body for POSTing to Parse */
    func makeDictionaryForPostLocation(mediaURL: String, mapString: String) -> [String : AnyObject]{
        let dictionary: [String : AnyObject] = [
            ParseClient.JSONResponseKeys.UniqueKey : UdaciousClient.sharedInstance().IDKey!,
            ParseClient.JSONResponseKeys.FirstName : UdaciousClient.sharedInstance().firstName!,
            ParseClient.JSONResponseKeys.LastName : UdaciousClient.sharedInstance().lastName!,
            ParseClient.JSONResponseKeys.Latitude : UdaciousClient.sharedInstance().latitude!,
            ParseClient.JSONResponseKeys.Longitude : UdaciousClient.sharedInstance().longitude!,
            ParseClient.JSONResponseKeys.GEODescriptor : mapString,
            ParseClient.JSONResponseKeys.MediaURL : mediaURL
        ]
        return dictionary
    }
}

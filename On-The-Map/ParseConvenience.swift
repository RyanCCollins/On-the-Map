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
        
        taskForGETMethod(Methods.StudentLocations, parameters: nil){ JSONResult, error in
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
        
        
        ParseClient.sharedInstance().queryParseDataForObjectId({ success, objectId, error in
            
            if success && objectId != nil {
                print("Succesfully updated")
                ParseClient.sharedInstance().updateLocationForObjectId(objectId!, JSONBody: locationParameters, completionHandler: {success, error in
                    
                    if error != nil {
                        
                        completionHandler(success: false, error: error)
                        
                    } else {
                        
                        completionHandler(success: true, error: nil)
                    }
                    
                })
                
            } else {
                
                ParseClient.sharedInstance().taskForPOSTMethod(ParseClient.Methods.StudentLocations, JSONBody: locationParameters, completionHandler: {success, error in
                    
                    if error != nil {
                        
                        completionHandler(success: false, error: error)
                    
                    } else {
                        
                        completionHandler(success: true, error: nil)
                        
                    }
                    
                })
                
            }
            
        })
        
        taskForPOSTMethod(Methods.StudentLocations, JSONBody: locationParameters) { result, error in
            
            if let error = error {
                
                completionHandler(success: false, error: error)
                
            } else {
                
                /* If we receive a response with an object ID, then we return true */
                if let objectID = result[JSONResponseKeys.ObjectID] as? String {

                    completionHandler(success: true, error: nil)
                    
                } else {
                    
                    completionHandler(success: false, error: ParseClient.errorFromString("Could not post data in postDataToParse"))
                    
                }
                
            }
            
        }
    }
    
    func queryParseDataForObjectId(completionHandler: (success: Bool, objectId: String?, error: NSError?) -> Void) {
        
        /* get data from Parse */
        taskForGETMethod(ParseClient.Methods.StudentLocations, parameters: [ ParseClient.JSONResponseKeys.UniqueKey : UdaciousClient.sharedInstance().IDKey!], completionHandler: {results, error in
            
            /* If there was an error parsing, return an error */
            if error != nil {
                
                ParseClient.errorFromString("Could not query data in query parse data method!")
                completionHandler(success: false, objectId: nil, error: error)
                
            } else {
                
                /* if results were returned, drill into the most recent objectId and return it */
                if let results = results[ParseClient.JSONResponseKeys.Results] as? [[String : AnyObject]] {
                
                    let studentDataArray = StudentLocationData.generateLocationDataFromResults(results)
                    
                    let objectId = studentDataArray[0].ObjectID
                
                        completionHandler(success: true, objectId: objectId, error: nil)
                    
                } else {
                    
                    completionHandler(success: false, objectId: nil, error: ParseClient.errorFromString("Failed to get object ID in queryDataForObjectID"))
                    
                }
            }
            
        })
        
    }
    
    
    func updateLocationForObjectId(objectId: String, JSONBody: [String : AnyObject], completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        taskForPUTMethod(ParseClient.Methods.StudentLocations, objectId: objectId, JSONBody: JSONBody, completionHandler: {success, error in
            
            if error != nil {

                completionHandler(success: false, error: error)

                
            } else {
                
                completionHandler(success: true, error: nil)
                
            }
            
        })
        
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

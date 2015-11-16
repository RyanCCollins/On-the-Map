//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import Foundation
import Parse

extension ParseClient {
    
    /* Get data for the students from parse */
    func getDataFromParse(completionHandler: (success: Bool, data: [StudentInformation]?, error: NSError?)->Void) {
        
        taskForGETMethod(Methods.StudentLocations, parameters: nil){ JSONResult, error in
            if let error = error {
                
                completionHandler(success: false, data: nil, error: error)
                
            } else {
                
                /* If results are returned and we are able to parse the data, return it as an array of studentData */
                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    
                    let studentData = StudentInformation.generateLocationDataFromResults(results)
                        
                        self.studentData = studentData
                        
                        completionHandler(success: true, data: self.studentData, error: nil)
                }
                
            }
        }
    }
    
    /* Either update object of post new if no objectId returned when querying */
    func postDataToParse(JSONBody: [String : AnyObject], objectId: String?, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        
            if objectId != nil {
                
                taskForPUTMethod(ParseClient.Methods.StudentLocations, objectId: objectId!, JSONBody: JSONBody, completionHandler: {success, error in
                    
                    if error != nil {
                        
                        completionHandler(success: false, error: error)
                        
                        
                    } else {
                        
                        /* Send a push notification showing updated */
                        self.pushNotificationForPOST(JSONBody)
                        completionHandler(success: true, error: nil)
                        
                    }
                    
                })

            } else {
                
            ParseClient.sharedInstance().taskForPOSTMethod(ParseClient.Methods.StudentLocations, JSONBody: JSONBody, completionHandler: {success, error in
                
                if error != nil {
                    
                    completionHandler(success: false, error: error)
                
                } else {
                    /* Send a push notification showing updated */
                    self.pushNotificationForPOST(JSONBody)
                    completionHandler(success: true, error: nil)
                    
                }
                
            })
            
        }
    
    }
    
    func queryParseDataForObjectId(completionHandler: (success: Bool, results: StudentInformation?, error: NSError?) -> Void) {
        
        /* get data from Parse */
        
        taskForGETMethod(ParseClient.Methods.StudentLocations, parameters: [ParseClient.Methods.Where : [ParseClient.JSONResponseKeys.UniqueKey : UdaciousClient.sharedInstance().IDKey!]], completionHandler: {results, error in

            /* If there was an error parsing, return an error */
            if error != nil {

                completionHandler(success: false, results: nil, error: error)
                
            } else {
                
                /* if results were returned, drill into the most recent objectId and return it */
                if let results = results[ParseClient.JSONResponseKeys.Results] as? [[String : AnyObject]] {

                    let studentDataArray = StudentInformation.generateLocationDataFromResults(results)
                    
                    let results = studentDataArray[0]

                        completionHandler(success: true, results: results, error: nil)
                    
                } else {
                    
                    completionHandler(success: false, results: nil, error: Errors.constructError(domain: "ParseClient", userMessage: ErrorMessages.Parse))
                    
                }
            }
            
        })
        
    }

    
    /* Show a push notification after successfully posting a location */
    func pushNotificationForPOST(JSONBody: [String : AnyObject]) {
        let push = PFPush()
        push.setChannel("global")
        
        
        if let mapString = JSONBody[ParseClient.JSONResponseKeys.GEODescriptor] {
            if let mediaString = JSONBody[ParseClient.JSONResponseKeys.MediaURL] {
                push.setMessage("You posted the following link: \(mediaString) from \(mapString)!")
                push.sendPushInBackground()
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

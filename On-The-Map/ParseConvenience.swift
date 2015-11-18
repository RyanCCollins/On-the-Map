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
    
    /* Get the most recent 100 results from Parse, Parse it and return in completion handler to be used. */
    func getMostRecentDataFromParse(completionHandler: (success: Bool, data: [StudentInformation]?, error: NSError?)->Void) {
        
        let parameters: [String :AnyObject] = [ParseClient.ParameterKeys.limit : 100, ParseClient.ParameterKeys.Order : "-\(ParseClient.JSONResponseKeys.UpdateTime)"]
        
        taskForGETMethod(Methods.StudentLocations, parameters: parameters, queryParameters: nil){ JSONResult, error in
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
    func postDataToParse(JSONBody: [String : AnyObject], completionHandler: (success: Bool, error: NSError?) -> Void) {
        
            if lastPostObjectId != nil {
                
                taskForPUTMethod(ParseClient.Methods.StudentLocations, objectId: lastPostObjectId!, JSONBody: JSONBody, completionHandler: {success, error in
                    
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
    
    /* Get data from Parse based on a query, limiting to the most recent post by you. */
    func queryParseDataForLastSubmission(completionHandler: (success: Bool, results: StudentInformation?, error: NSError?) -> Void) {
        
       /* Limit to only the most recent submission, orderered by update time. */
        let parameters: [String : AnyObject] = [
            ParseClient.ParameterKeys.Order : "-\(ParseClient.JSONResponseKeys.UpdateTime)"
        ]
        
        let queryParameters: [String : AnyObject] = [ParseClient.QueryArguments.Where : [ParseClient.JSONResponseKeys.UniqueKey : UdaciousClient.sharedInstance().IDKey!]]
        
        taskForGETMethod(ParseClient.Methods.StudentLocations, parameters: parameters, queryParameters: queryParameters, completionHandler: {results, error in

            /* If there was an error parsing, return an error */
            if error != nil {

                completionHandler(success: false, results: nil, error: error)
                
            } else {
                
                /* If results were returned, drill into the most recent objectId and return it */
                if let results = results[ParseClient.JSONResponseKeys.Results] as? [[String : AnyObject]] {

                    let studentDataArray = StudentInformation.generateLocationDataFromResults(results)
                    
                    /* Ensure we have exactly on set of results and that it's the most recent */
                    let result = studentDataArray[0]
                        print(result)
                        /* Set shared instance's lastPostObjectId to update location */
                        self.lastPostObjectId = result.ObjectID
                        completionHandler(success: true, results: result, error: nil)
                    
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
    
}

//
//  ParseClient.swift
//  On The Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
    var session: NSURLSession?
    var studentData: [StudentInformation]?
    var lastPostObjectId: String?
    
    /* Task returned for GETting data from the Parse server, takes a method to call, an optional dictionary of paramaters that are automatically escpaed and an optional query argument, which will be prepended to the URL request. */
    func taskForGETMethod (method: String, parameters: [String : AnyObject]?, queryArgument: String?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var urlString = Constants.baseURLSecure + method
        
        /* If our request includes parameters, add those parameters to our URL */
        if parameters != nil {
            urlString += ParseClient.stringByEscapingParameters(parameters!, queryArgument: queryArgument)
            print(urlString)
        }
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        request.HTTPMethod = HTTPRequest.GET
        request.addValue(Constants.app_id, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.api_key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        
        /*Create a session and then a task */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                
              completionHandler(result: nil, error: Errors.constructError(domain: "ParseClient", userMessage: ErrorMessages.Status.Network))
                
            } else {
                
                /* GUARD: Did we get a successful response code of 2XX? */
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    var statusError: NSError?
                    
                    if let response = response as? NSHTTPURLResponse {
                        if response.statusCode >= 400 && response.statusCode <= 599 {
                            statusError = Errors.constructError(domain: "ParseClient", userMessage: ErrorMessages.Status.Auth)
                        }
                    } else {
                        statusError = Errors.constructError(domain: "ParseClient", userMessage: ErrorMessages.Status.InvalidResponse)
                    }
                    completionHandler(result: nil, error: statusError)
                    return
                }
                
                
                /* Parse the results and return in the completion handler with an error if there is one. */
                ParseClient.parseJSONDataWithCompletionHandler(data!, completionHandler: completionHandler)
                
            }
        }
        task.resume()
        return task
    }
    
    /* Task returned for POSTing data from the Parse server */
    func taskForPOSTMethod (method: String, JSONBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let urlString = Constants.baseURLSecure + method
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        request.HTTPMethod = HTTPRequest.POST
        request.addValue(Constants.app_id, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.api_key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(JSONBody, options: .PrettyPrinted)
        } catch {
            
            request.HTTPBody = nil
            completionHandler(result: nil, error: Errors.constructError(domain: "ParseClient", userMessage: ErrorMessages.JSONSerialization))
            
        }
        
        /*Create a session and then a task.  Parse results if no error. */
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                
                completionHandler(result: nil, error: Errors.constructError(domain: "ParseClient", userMessage: ErrorMessages.Status.Network))
                
            } else {
                
                /* GUARD: Did we get a successful response code of 2XX? */
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    var statusError: NSError?
                    
                    if let response = response as? NSHTTPURLResponse {
                        if response.statusCode >= 400 && response.statusCode <= 599 {
                            statusError = Errors.constructError(domain: "ParseClient", userMessage: ErrorMessages.Status.Auth)
                        }
                    } else {
                        statusError = Errors.constructError(domain: "ParseClient", userMessage: ErrorMessages.Status.InvalidResponse)
                    }
                    completionHandler(result: nil, error: statusError)
                    return
                }
                
                /* Parse the results and return in the completion handler with an error if there is one. */
                ParseClient.parseJSONDataWithCompletionHandler(data!, completionHandler: completionHandler)
                
            }
        }
        task.resume()
        return task
    }
    
    
    /* Update a user's location */
    func taskForPUTMethod(method: String, objectId: String, JSONBody : [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString = ParseClient.Constants.baseURLSecure + method + "/" + objectId

        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        request.HTTPMethod = HTTPRequest.PUT
        request.addValue(Constants.app_id, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.api_key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(JSONBody, options: .PrettyPrinted)
            
        } catch {
            request.HTTPBody = nil
            completionHandler(result: nil, error: Errors.constructError(domain: "ParseClient", userMessage: ErrorMessages.JSONSerialization))
            
        }
        
        /*Create a session and then a task.  Parse results if no error. */
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                
                completionHandler(result: nil, error: Errors.constructError(domain: "ParseClient", userMessage: ErrorMessages.Status.Network))
                
            } else {
                
                /* GUARD: Did we get a successful response code of 2XX? */
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    var statusError: NSError?
                    
                    if let response = response as? NSHTTPURLResponse {
                        if response.statusCode >= 400 && response.statusCode <= 599 {
                            statusError = Errors.constructError(domain: "ParseClient", userMessage: ErrorMessages.Status.Auth)
                        }
                    } else {
                        statusError = Errors.constructError(domain: "ParseClient", userMessage: ErrorMessages.Status.InvalidResponse)
                    }
                    completionHandler(result: nil, error: statusError)
                    return
                }
                
                /* Parse the results and return in the completion handler with an error if there is one. */
                ParseClient.parseJSONDataWithCompletionHandler(data!, completionHandler: completionHandler)
                
            }
        }
        task.resume()
        return task

    }
    
    /* Helper Function: Convert JSON to a Foundation object */
    class func parseJSONDataWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandler(result: nil, error: Errors.constructError(domain: "ParseClient", userMessage: ErrorMessages.Parse))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    /* Helper Function: Given a dictionary of parameters, convert to a string for a url */
    class func stringByEscapingParameters(parameters: [String : AnyObject], queryArgument: String?) -> String {
        print(parameters)
        var urlVarArray = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that we have a string for safety */
            let stringValue = "\(value)"

            /* Escape the parameters and then append it to the urlVarArray object */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            urlVarArray += [key + ":" + "\(escapedValue!)"]
        }
        
        /* As long as the array is not empty, construct a string to return.  If a query argument is defined, prepend it to our string and continue building the url */
        return (queryArgument == nil ? "?" : "?\(queryArgument!)=") + urlVarArray.joinWithSeparator("&")
    }
    
    /* Helper function, creates JSON Body for POSTing to Parse, keeping data encapsulated within each client */
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
    
    /* Singleton shared instance of ParseClient */
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}

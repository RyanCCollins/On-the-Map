//
//  ParseClient.swift
//  On The Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import Foundation

class ParseClient: NSObject {
    var session: NSURLSession?
    var studentData: [StudentInformation]?
    var lastPostObjectId: String?
    
    /* Task returned for GETting data from the Parse server */
    func taskForGETMethod (method: String, parameters: [String : AnyObject]?, queryParameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var urlString = Constants.baseURLSecure + method
        
        /* If our request includes parameters, add those parameters to our URL */
        if parameters != nil {
            urlString += ParseClient.stringByEscapingParameters(parameters!, queryParameters: queryParameters)
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
    
    /* Helper Function: Given an optional dictionary of parameters and an optional dictionary of query parameters, convert to a URL encoded string */
    class func stringByEscapingParameters(parameters: [String : AnyObject]?, queryParameters: [String : AnyObject]?) -> String {
        print(parameters)
        var components = [String]()
        
        
        if parameters != nil {
            components.append(URLString(fromParameters: parameters!, withSeperator: ":"))
        }
        
        if queryParameters != nil {
            components.append(URLString(fromParameters: queryParameters!, withSeperator: "="))
        }
        
        return (!components.isEmpty ? "?" : "") + components.joinWithSeparator("&")
        
    }
    
    /* Helper function builds a parameter or query string based on a dictionary of parameters.  Takes a string as an argument called seperator, which is used as : for parameters and = for queries */
    class func URLString(fromParameters parameters: [String : AnyObject], withSeperator seperator: String) -> String {
        var queryComponents = [(String, String)]()
        
        for (key, value) in parameters {
            queryComponents += recursiveURLComponents(key, value)
        }
        
        return (queryComponents.map {"\($0)\(seperator)\($1)" } as [String]).joinWithSeparator("&")
        
    }
    
    /* Recursively construct a query string from parameters:
    Takes a key from a dictionary as a String and its relate parameters of AnyObject and traverses through
    the parameters, building an array of String tuples containing the key value pairs 
    This is used to construct components for complex queries and parameter calls that are more than just String : String.
    The parameter object can be a dictionary, array or string.
    */
    class func recursiveURLComponents(keyString : String, _ parameters: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let parameterDict = parameters as? [String : AnyObject] {
        for (key, value) in parameterDict {
                components += recursiveURLComponents("\(keyString)[\(key)]", value)
            }
        } else if let parameterArray = parameters as? [AnyObject] {
            for parameter in parameterArray {
                components += recursiveURLComponents("\(keyString)[]", parameter)
            }

        } else {
            components.append((escapedString(keyString), escapedString("\(parameters)")))
        }
        return components
    }
    
    /* Helper function, takes a string as an argument and returns an escaped version of it to be sent in an HTTP Request */
    class func escapedString(string: String) -> String {
        let escapedString = string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        return escapedString!
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
    
    /* Shared date formatter for Parse Client dates returned */
    class var sharedDateFormatter: NSDateFormatter {
        struct Singleton {
            static let dateFormatter = Singleton.generateDateFormatter()
            
            static func generateDateFormatter() -> NSDateFormatter {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-mm-dd"
                
                return formatter
            }
        }
        return Singleton.dateFormatter
    }
}

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
    var studentData: [StudentLocationData]?
    
    /* Task returned for GETting data from the Parse server */
    func taskForGETMethod (method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let urlString = Constants.baseURLSecure + method
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        request.HTTPMethod = HTTPRequest.GET
        request.addValue(Constants.app_id, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.api_key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        
        /*Create a session and then a task */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                
              completionHandler(result: nil, error: error)
                
            } else {
                
                /* GUARD: Did we get a successful response code of 2XX? */
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    var statusError = "taskForGETMethod request returned an invalid response!"
                    if let response = response as? NSHTTPURLResponse {
                        statusError += " Status code: \(response.statusCode)!"
                    } else if let response = response {
                        statusError += " Response: \(response)!"
                    }
                    completionHandler(result: nil, error: UdaciousClient.errorFromString(statusError))
                    return
                }
                
                
                /* Parse the results and return in the completion handler with an error if there is one. */
                if let parsedResults = (try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)) as? [String : AnyObject] {
                    
                    /* if response has a status and an error message, return it in completion handler */
                    if let status = parsedResults[ParseClient.JSONResponseKeys.Status] as? String {
                        
                        let errorResponse = parsedResults[ParseClient.JSONResponseKeys.Error] as! String
                        
                        completionHandler(result: parsedResults, error: ParseClient.errorFromString("\(status) \(errorResponse)"))

                    } else {
                    
                        completionHandler(result: parsedResults, error: nil)
    
                    }
                    
                }
                
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
            
            print("failed to create a request body in taskForPOSTMethod of ParseClient")
            request.HTTPBody = nil
            
        }
        
        /*Create a session and then a task.  Parse results if no error. */
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if let error = error {
                
                completionHandler(result: nil, error: error)
                
            } else {
                
                /* GUARD: Did we get a successful response code of 2XX? */
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    var statusError = "taskForPOSTMethod request returned an invalid response!"
                    if let response = response as? NSHTTPURLResponse {
                        statusError += " Status code: \(response.statusCode)!"
                    } else if let response = response {
                        statusError += " Response: \(response)!"
                    }
                    completionHandler(result: nil, error: UdaciousClient.errorFromString(statusError))
                    return
                }
                
                /* Parse the results and return in the completion handler with an error if there is one. */
                if let parsedResults = (try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)) as? [String : AnyObject] {
                    
                    if let errorResponse = parsedResults[ParseClient.JSONResponseKeys.Error] as? String {
                        
                        completionHandler(result: parsedResults, error: ParseClient.errorFromString(errorResponse))
                        
                    } else {
                        
                        completionHandler(result: parsedResults, error: nil)
                        
                    }
                    
                }
                
            }
        }
        task.resume()
        return task
    }
    
    
    /* Helper: Given a method, swap the key with the value: */
    class func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        
        if method.rangeOfString("{\(key)}") != nil {
            
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
            
        } else {
            
            return nil
            
        }
    }
    
    /* Helper function: construct an NSLocalizedError from an error string */
    class func errorFromString(string: String) -> NSError? {
        
        return NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(string)"])
        
    }
    
    
    /* Helper Function: Convert JSON to a Foundation object */
    class func parseJSONDataWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Failed to parse data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 0, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    /* Helper Function: Given a dictionary of parameters, convert to a string for a url */
    class func stringByEscapingParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVarArray = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that we have a string for safety */
            let stringValue = "\(value)"
            
            /* Escape the parameters and then append it to the urlVarArray object */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            urlVarArray += [key + "=" + "\(escapedValue!)"]
            
        }
        
        /* As long as the array is not empty, construct a string to return */
        return (!urlVarArray.isEmpty ? "?" : "") + urlVarArray.joinWithSeparator("&")
    }
    
    /* Singleton shared instance of ParseClient */
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}

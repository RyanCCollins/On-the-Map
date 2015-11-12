//
//  UdaciousClient.swift
//  On-The-Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class UdaciousClient: NSObject {
    /* session variables */
    var session: NSURLSession
    var IDKey: String? = nil
    var sessionID: String? = nil
    var firstName:String? = nil
    var lastName:String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    var mapString: String? = nil
    var mediaURL: String? = nil

    
    /* Use the shared NSURlSession: */
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    func taskForGETMethod(method: String, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL, using parameters if there are any */
        var urlString = Constants.BaseURLSecure + method
        if let parameters = parameters {
            urlString += UdaciousClient.stringByEscapingParameters(parameters)
        }
        
        let url = NSURL(string: urlString)
        
        /* 3. Make the request */
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = UdaciousClient.HTTPRequest.GET

        let session = NSURLSession.sharedSession()
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* Guard for an error */
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            
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
            
            /* Make sure the data is parsed before returning it */
            let usableData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            if let parsedData = (try? NSJSONSerialization.JSONObjectWithData(usableData, options: .AllowFragments)) as? [ String : AnyObject]{
                completionHandler(result: parsedData, error: nil)
            } else {
                print("Failed to parse data to JSON in taskForGETMethod")
                completionHandler(result: nil, error: UdaciousClient.errorFromString("Failed to parse data to JSON in taskForGETMethod"))
            }
            completionHandler(result: data, error: nil)
        }
        task.resume()
        return task
    }
    
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL */
        let urlString = Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)
        
        /* Make the request */
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters!, options: .PrettyPrinted)
        } catch let error as NSError {
            request.HTTPBody = nil
            print(error)
            completionHandler(result: nil, error: error)
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* GUARD: was there an error? */
            guard error == nil else {
                completionHandler(result: nil, error: UdaciousClient.errorFromString("An error occured while initializing the task in taskForPOSTMethod in UdaciousClient"))
                return
            }
            
            
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


            let usableData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            if let parsedData = (try? NSJSONSerialization.JSONObjectWithData(usableData, options: .AllowFragments)) {
                
            completionHandler(result: parsedData, error: nil)
                
            } else {
                
                print("Failed to parse data to JSON in taskForPostMethod")
                
                completionHandler(result: nil, error: UdaciousClient.errorFromString("Failed to parse data to JSON in taskForPostMethod"))
            }
        }
        
        task.resume()
        
        return task
    }
    
    /* Delete (logout) a session */
    func taskForDELETEMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Configure URL */
        let urlString = Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)
        
        /* Make the request */
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = UdaciousClient.HTTPRequest.DELETE
        
        /* MMM.. Cookies*/
        var xsrfCookie: NSHTTPCookie? = nil
        
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        if let cookies = sharedCookieStorage.cookies as [NSHTTPCookie]! {
        
            for cookie in cookies {
            
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* GUARD: was there an error? */
            guard error == nil else {
                
                completionHandler(result: nil, error: UdaciousClient.errorFromString("An error occured while initializing the task in taskForDELETEMethod in UdaciousClient"))
                
                return
            }
            
            
            /* GUARD: Did we get a successful response code of 2XX? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                var statusError = "taskForDELETEMethod request returned an invalid response!"
                
                if let response = response as? NSHTTPURLResponse {
                    
                    statusError += " Status code: \(response.statusCode)!"
                
                } else if let response = response {
                    
                    statusError += " Response: \(response)!"
                
                }
                
                completionHandler(result: nil, error: UdaciousClient.errorFromString(statusError))
                return
            }
            
            /* Parse JSON into a Foundation data object */
            let usableData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            if let parsedData = (try? NSJSONSerialization.JSONObjectWithData(usableData, options: .AllowFragments)) {
                completionHandler(result: parsedData, error: nil)
            } else {
                print("Failed to parse data to JSON in taskForPostMethod")
                completionHandler(result: nil, error: UdaciousClient.errorFromString("Failed to parse data to JSON in taskForPostMethod"))
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
        return NSError(domain: "UdaciousClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(string)"])
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
    
    /* Singleton shared instance of UdaciousClient */
    class func sharedInstance() -> UdaciousClient {
        
        struct Singleton {
            
            static var sharedInstance = UdaciousClient()
            
        }
        
        return Singleton.sharedInstance
    }
}

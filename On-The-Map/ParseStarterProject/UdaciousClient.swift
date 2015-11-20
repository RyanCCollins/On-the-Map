//
//  UdaciousClient.swift
//  On-The-Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//
/* NOTE: Research for this class was done prior to implementation.  This class was entirely written by me based on the research of several other Swift API Clients, including, but not limited to: Udacity's TMDBClient and the popular Swift Networking API named AlamoFire.  https://github.com/Alamofire/Alamofire

*/


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
    var imageURL: String? = nil

    
    /* Use the shared NSURlSession: */
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    /* Task for GETting data from Udacity */
    func taskForGETMethod(method: String, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL, using parameters if there are any */
        var urlString = Constants.BaseURLSecure + method
        
        if let parameters = parameters {
            
            urlString += UdaciousClient.stringByEscapingParameters(parameters, queryParameters: nil)
            
        }
        
        let url = NSURL(string: urlString)
        
        /* Make the request */
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = UdaciousClient.HTTPRequest.GET

        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* Guard for an error connecting to network */
            guard error == nil else {
                completionHandler(result: nil, error: Errors.constructError(domain: "UcaciousClient", userMessage: ErrorMessages.Status.Network))
                return
            }
            
            self.guardForHTTPResponses(response as? NSHTTPURLResponse) {proceed, error in
                if error != nil {
                    
                    completionHandler(result: nil, error: error)
                    
                } 
            }
            
            /* Make sure the data is parsed before returning it */

            let usableData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))

            UdaciousClient.parseJSONDataWithCompletionHandler(usableData, completionHandler: completionHandler)
            
            completionHandler(result: data, error: nil)
            
        }
        task.resume()
        return task
    }
    
    /* Task for POSTing data */
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL */
        let urlString = Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)
        
        /* Construct the request */
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        /* Try to run the request with error catching */
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters!, options: .PrettyPrinted)
        } catch {
            request.HTTPBody = nil

            completionHandler(result: nil, error: Errors.constructError(domain: "UdaciousClient", userMessage: "An error occured while getting data from the network."))
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* GUARD: was there an error? */
            guard error == nil else {
                completionHandler(result: nil, error: Errors.constructError(domain: "UcaciousClient", userMessage: ErrorMessages.Status.Network))
                return
            }
            
            
            /* GUARD: Did we get a successful response code of 2XX? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                var statusError: NSError?
                
                if let response = response as? NSHTTPURLResponse {
                    if response.statusCode >= 400 && response.statusCode <= 599 {
                        statusError = Errors.constructError(domain: "UdaciousClient", userMessage: ErrorMessages.Status.Auth)
                    }
                } else {
                    statusError = Errors.constructError(domain: "UdaciousClient", userMessage: ErrorMessages.Status.InvalidResponse)
                }
                completionHandler(result: nil, error: statusError)
                return
            }


            let usableData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
           UdaciousClient.parseJSONDataWithCompletionHandler(usableData, completionHandler: completionHandler)
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
                
                completionHandler(result: nil, error: Errors.constructError(domain: "UdaciousClient", userMessage: ErrorMessages.Status.Network))
                return
            }
            
            
            /* GUARD: Did we get a successful response code of 2XX? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                var statusError: NSError?
                
                if let response = response as? NSHTTPURLResponse {
                    if response.statusCode >= 400 && response.statusCode <= 599 {
                        statusError = Errors.constructError(domain: "UdaciousClient", userMessage: ErrorMessages.Status.Auth)
                    }
                } else {
                    statusError = Errors.constructError(domain: "UdaciousClient", userMessage: ErrorMessages.Status.InvalidResponse)
                }
                completionHandler(result: nil, error: statusError)
                return
            }
            
            /* Parse JSON into a Foundation data object */
            let usableData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            UdaciousClient.parseJSONDataWithCompletionHandler(usableData, completionHandler: completionHandler)
            
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

    
    /* Helper Function: Convert JSON to a Foundation object */
    class func parseJSONDataWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
        } catch {
            completionHandler(result: nil, error: Errors.constructError(domain: "UdaciousClient", userMessage: ErrorMessages.Parse))
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
    
    /*
    The following functions are a mashup of several ideas that I recreated in order to query REST APIs.
    This function recursively construct a query string from parameters:
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
    
    /* Abstraction of repetive guard statements in each request function */
    func guardForHTTPResponses(response: NSHTTPURLResponse?, completionHandler: (proceed: Bool, error: NSError?) -> Void) -> Void {
        /* GUARD: Did we get a successful response code of 2XX? */
        guard let statusCode = response?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            var statusError: NSError?
            
            /* IF not, what was our status code?  Provide appropriate error message and return */
            if let response = response {
                if response.statusCode >= 400 && response.statusCode <= 599 {
                    statusError = Errors.constructError(domain: "UdaciousClient", userMessage: ErrorMessages.Status.Auth)
                }
            } else {
                statusError = Errors.constructError(domain: "UdaciousClient", userMessage: ErrorMessages.Status.InvalidResponse)
            }
            completionHandler(proceed: false, error: statusError)
            return
        }
        completionHandler(proceed: true, error: nil)
    }
    
    /* Singleton shared instance of UdaciousClient */
    class func sharedInstance() -> UdaciousClient {
        
        struct Singleton {
            
            static var sharedInstance = UdaciousClient()
            
        }
        
        return Singleton.sharedInstance
    }
}

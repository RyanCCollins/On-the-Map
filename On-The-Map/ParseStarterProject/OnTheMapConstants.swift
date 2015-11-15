//
//  OnTheMapConstants.swift
//  On The Map
//
//  Created by Ryan Collins on 11/14/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import Foundation


/* Helper properties to get a_sync queues */
var GlobalMainQueue: dispatch_queue_t {
    return dispatch_get_main_queue()
}

var GlobalUserInteractiveQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
}

var GlobalUserInitiatedQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
}

var GlobalUtilityQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
}

var GlobalBackgroundQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
}


/* Define global errors */
struct GlobalErrors : ErrorType {
    
    static let LogoutError = NSError(domain: "Global", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occured while trying to logout."])
    static let GenericNetworkError = NSError(domain: "Global", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occured while getting data from the network."])
    static let GenericError = NSError(domain: "Global", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occured.  Please try again."])
    static let MissingData = NSError(domain: "Global", code: 0, userInfo: [NSLocalizedDescriptionKey : "Missing something.  Please make sure all text fields are filled out appropriately."])
    static let InvalidURL = NSError(domain: "Global", code: 0, userInfo: [NSLocalizedDescriptionKey : "The link is not valid.  Please try again."])
    static let GEOCode = NSError(domain: "Global", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not geocode your location.  Enter a more specific location and try again."])
    static let BadCredentials = NSError(domain: "Global", code: 0, userInfo: [NSLocalizedDescriptionKey : "Please enter a valid email address and password."])
    static let LogOut = NSError(domain: "Global", code: 0, userInfo: [NSLocalizedDescriptionKey : "Failed to logout of session.  Please try again."])
}

/* Define errors within domain of Parse Client */
struct ParseErrors : ErrorType {
    
    static let JSONSerialization =  NSError(domain: "UdaciousClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occured when sending data to the network."])
    static let Parse =  NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occured while getting data from the network."])
    
    struct Status {
        static let Auth401 =  NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "The network returned an invalid response due to invalid credentials.  Please try again."])
        static let InvalidResponse = NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unable to log you in due to an invalid response from the server.  Please try again."])
        static let Network = NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not connect to the network.  Please try again."])
    }
    
}

struct UdaciousErrors : ErrorType {
    
    static let JSONSerialization =  NSError(domain: "UdaciousClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occured when sending data to the network."])
    static let Parse =  NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occured while getting data from the network."])
    
    struct Status {
        static let Auth401 =  NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "The network returned an invalid response due to invalid credentials.  Please try again."])
        static let InvalidResponse = NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unable to log you in due to an invalid response from the server.  Please try again."])
        static let Network = NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not connect to the network.  Please try again."])
    }
}
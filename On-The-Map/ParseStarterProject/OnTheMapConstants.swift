//
//  OnTheMapConstants.swift
//  On The Map
//
//  Created by Ryan Collins on 11/14/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import Foundation

struct AlertActions {
    
    static let NetworkMessage = "Failed to connect to the network"
    static let VerificationMessage = "Failed to verify your credentials, please try again"
    
    

    
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
}
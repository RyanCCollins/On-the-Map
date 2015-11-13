//
//  StudentLocationData
//  On The Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

struct StudentLocationData {
    
    var First: String!
    var Last: String!
    var MediaUrl: String!

    var Latitude: Double!
    var Longitude: Double!
    var GEODescriptor: String!

    var ObjectID: String!
    var UniqueKey: String!
    var UpdateTime: String!
    
    var userImageURL: String?
    
    init(studentLocationDictionary: [String : AnyObject]) {
        /* Initialize data from studentLocationDictionary */
        First = studentLocationDictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        Last = studentLocationDictionary[ParseClient.JSONResponseKeys.LastName] as! String
        Latitude = studentLocationDictionary[ParseClient.JSONResponseKeys.Latitude] as! Double
        Longitude = studentLocationDictionary[ParseClient.JSONResponseKeys.Longitude] as! Double
        GEODescriptor = studentLocationDictionary[ParseClient.JSONResponseKeys.GEODescriptor] as! String
        ObjectID = studentLocationDictionary[ParseClient.JSONResponseKeys.ObjectID] as! String
        UniqueKey = studentLocationDictionary[ParseClient.JSONResponseKeys.UniqueKey] as! String
        UpdateTime = studentLocationDictionary[ParseClient.JSONResponseKeys.UpdateTime] as! String
        MediaUrl = studentLocationDictionary[ParseClient.JSONResponseKeys.MediaURL] as! String
        
        if let userImageURL = studentLocationDictionary[ParseClient.JSONResponseKeys.UserImageURL] as? String {
            self.userImageURL = userImageURL
        }
    }
    
    /* Create an array of student location data from results returned by ParseClient */
    static func generateLocationDataFromResults(results: [[String : AnyObject]]) -> [StudentLocationData] {
        var locationDataArray = [StudentLocationData]()
    
    for result in results {
    
        locationDataArray.append(StudentLocationData(studentLocationDictionary: result))
    
    }
        /* Sort location data to be most recent first */
        locationDataArray.sortInPlace({
            $0.UpdateTime > $1.UpdateTime
        })
    return locationDataArray
    }
    
}

//
//  StudentLocationData
//  On The Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

struct StudentLocationData {
    
        let First: String!
        let Last: String!
        let MediaUrl: String!

        let Latitude: Double!
        let Longitude: Double!
        let GEODescriptor: String!

        let ObjectID: String!
        let UniqueKey: String!
        let UpdateTime: String!
    
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
    }
    
    /* Create an array of student location data from results */
    func generateLocationDataFromResults(results : [[String : AnyObject]]) -> [StudentLocationData] {
        var locationData = [StudentLocationData]()
    
    for result in results {
    
        locationData.append(StudentLocationData(studentLocationDictionary: result))
    
    }
        /* Sort location data to be most recent first */
        locationData.sortInPlace({
            $0.UpdateTime > $1.UpdateTime
        })
    return locationData
    }
}

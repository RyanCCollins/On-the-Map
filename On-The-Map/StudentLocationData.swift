//
//  StudentLocationData
//  On The Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

struct StudentLocationData {
    
    struct Name {
        let First: String?
        let Last: String?
    }
    
    struct Geo {
        let Latitude: Double?
        let Longitude: Double?
        let Descriptor: String?
    }
    
    struct Object {
        let ID: String?
        let Key: String?
        let UpdateTime: String?
    }
    
    init(studentLocationDictionary: [String : AnyObject]) {
        /* Initialize data from studentLocationDictionary */
        Name.First = studentLocationDictionary[ParseClient.JSONResponseKeys.Name.First] as String
        Name.Last = studentLocationDictionary[ParseClient.JSONResponseKeys.Name.Last]
        Geo.Latitude = studentLocationDictionary[ParseClient.JSONResponseKeys.Geo.Last]
        Geo.Longitude = studentLocationDictionary[ParseClient.JSONResponseKeys.Geo.Longitude]
        Object.ID = studentLocationDictionary[ParseClient.JSONResponseKeys.Object.ID]
        Object.Key = studentLocationDictionary[ParseClient.JSONResponseKeys.Object.Key]
        Object.UpdateTime = studentLocationDictionary[ParseClient.JSONResponseKeys.Object.UpdateTime]
    }
}

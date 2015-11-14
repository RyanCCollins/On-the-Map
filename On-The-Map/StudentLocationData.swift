//
//  StudentLocationData
//  On The Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import Foundation

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
    var ImageURL: NSURL?
    
    init(studentLocationDictionary: [String : AnyObject]) {
        /* Initialize data from studentLocationDictionary */
        First = studentLocationDictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        Last = studentLocationDictionary[ParseClient.JSONResponseKeys.LastName] as! String
        Latitude = studentLocationDictionary[ParseClient.JSONResponseKeys.Latitude] as! Double
        Longitude = studentLocationDictionary[ParseClient.JSONResponseKeys.Longitude] as! Double
        GEODescriptor = studentLocationDictionary[ParseClient.JSONResponseKeys.GEODescriptor] as! String
        ObjectID = studentLocationDictionary[ParseClient.JSONResponseKeys.ObjectID] as! String
        UniqueKey = studentLocationDictionary[ParseClient.JSONResponseKeys.UniqueKey] as! String
        MediaUrl = studentLocationDictionary[ParseClient.JSONResponseKeys.MediaURL] as! String
        
        
        if let ImageURL =  NSURL(string: "https:" + "\(UdaciousClient.sharedInstance().imageURL!)") {
            self.ImageURL = ImageURL
        }
        
        UpdateTime = studentLocationDictionary[ParseClient.JSONResponseKeys.UpdateTime] as! String
//        if let UpdateTime = formatDateString(studentLocationDictionary[ParseClient.JSONResponseKeys.UpdateTime] as! String) {
//            print(UpdateTime)
//            self.UpdateTime = UpdateTime
//        }
    }
    
    /* Handle date/time formatting, when applicable */
    func formatDateString(dateString: String) -> NSDate? {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("MM-dd-yyyy h:mm", options: 0, locale: NSLocale(localeIdentifier: "en-US"))
        
        if let formattedDate = dateFormatter.dateFromString(dateString) {
            return formattedDate
        }
        return nil
        
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

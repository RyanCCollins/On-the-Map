//
//  MapViewController.swift
//  On-The-Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import Parse
import MapKit
import MBProgressHUD
import SwiftSpinner

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var studentLocationMapView: MKMapView!
    let initialLocation = CLLocation(latitude: 37.399872, longitude: -122.108296)
    let regionRadius: CLLocationDistance = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get shared session */
        ParseClient.sharedInstance()
        refreshViewForDataUpdate()
        studentLocationMapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidAppear(animated: Bool) {

    }
    
    /* refresh the view for data update/retrieval - call asynchronously*/
    func refreshViewForDataUpdate() {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            SwiftSpinner.show("Updating...").addTapHandler({
                SwiftSpinner.hide()
            })
            
        })
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            self.loadMapViewWithParseData({success, error in
                if error != nil {
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                    let logoutAction = UIAlertAction(title: "Logout", style: .Destructive, handler: { Void in
                        self.logoutOfSession()
                    })
                    let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: { Void in
                        self.loadMapViewWithParseData(nil)
                    })
                    
                    self.alertUserWithWithActions("Failed to refresh data", message: "Something went wrong while refreshing the data.  Please retry or logout", actions: [logoutAction, retryAction])
                    
                } else {
                    
                    
                    
                }
                
                SwiftSpinner.hide()
                
            })
        })
        
        
            
    }
    
    /* add parse data to map if first time logging in, get the data, if not, get the shared instance of student data */
    func loadMapViewWithParseData(completionHandler: ((success: Bool, error: NSError?)-> Void)?) {
        
        if let locations = ParseClient.sharedInstance().studentData {
            
            addPinsToMapForStudents(locations)
            completionHandler!(success: true, error: nil)

        } else {
            ParseClient.sharedInstance().getDataFromParse({success, results, error in
                
                if success {
                    
                    self.addPinsToMapForStudents(results)
                    completionHandler!(success: true, error: nil)
                    
                } else {
                    completionHandler!(success: false, error: self.errorFromString("Failed to load map with parsed data in loadMapWithParsedData"))
                }
                
            })
        }
        
        
            completionHandler!(success: true, error: nil)
        
    }
    
    func addPinsToMapForStudents(studentLocations: [StudentLocationData]?) {
        
        var annotations = [MKPointAnnotation]()
        
        if let studentLocations = studentLocations {
            
            for location in studentLocations {
                
                /* initialize objects for map */
                let firstName = location.First
                let lastName = location.Last
                let GEODescriptor = location.GEODescriptor
                let mediaURL = location.MediaUrl
                
                let latitude = CLLocationDegrees(location.Latitude)
                let longitude = CLLocationDegrees(location.Longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL
                
                
                annotations.append(annotation)
                
            }
            /* TODO: Add activity indicator */
            self.studentLocationMapView.addAnnotations(annotations)
            
        }
        
    }

    
    /* Center on location of map */
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        studentLocationMapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    
    /* Find current location and zoom in */
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let center = CLLocationCoordinate2D(latitude: (userLocation.location?.coordinate.latitude)!, longitude: (userLocation.location?.coordinate.longitude)!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            let appDelegate = UIApplication.sharedApplication()
            
            if let urlString = view.annotation?.subtitle! {
                
                appDelegate.openURL(NSURL(string: urlString)!)
                
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if (annotation is MKUserLocation) {
            
            return nil
        }
        
        
        let pin = "pin"
        
        var pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pin) as? MKPinAnnotationView
        if pinAnnotationView  == nil {
        pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pin)
        pinAnnotationView?.canShowCallout = true
        pinAnnotationView?.pinTintColor = UIColor.greenColor()
        pinAnnotationView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        } else {
            pinAnnotationView?.annotation = annotation
        }
    
        return pinAnnotationView
        
    }

    /* Zoom in on Udacity headquarters */
    @IBAction func didTapUdacityTouchUpInsided(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            
            self.centerMapOnLocation(self.initialLocation)
            
        })
    }

}

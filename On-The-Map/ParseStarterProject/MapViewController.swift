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

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var studentLocationMapView: MKMapView!
    let initialLocation = CLLocation(latitude: 37.399872, longitude: -122.108296)
    let regionRadius: CLLocationDistance = 1000
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get shared session */
        ParseClient.sharedInstance()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()
        loadMapViewWithParseData({success, error in
            if let error = error {
                print(error)
            }
        })
        
        activityIndicator.alpha = 0.0
        activityIndicator.stopAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {

    }
    
    /* add parse data to map if first time logging in, get the data, if not, get the shared instance of student data */
    func loadMapViewWithParseData(completionHandler: (success: Bool, error: NSError?)-> Void) {
        
        if let locations = ParseClient.sharedInstance().studentData {
            
            addPinsToMapForStudents(locations)
            completionHandler(success: true, error: nil)

        } else {
            ParseClient.sharedInstance().getDataFromParse({success, results, error in
                
                if success {
                    
                    self.addPinsToMapForStudents(results)
                    completionHandler(success: true, error: nil)
                } else {
                    completionHandler(success: false, error: self.errorFromString("Failed to load map with parsed data in loadMapWithParsedData"))
                }
                
            })
        }
        
        
            completionHandler(success: true, error: nil)
        
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
//            studentLocationMapView.addAnnotations(annotations)
            updateMapPointsAsync(annotations)
            
        }
        
    }
    
    func updateMapPointsAsync(annotations: [MKAnnotation]){
        dispatch_async(dispatch_get_main_queue(), {
            self.studentLocationMapView.addAnnotations(annotations)
        })
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
    
    @IBAction func didTapUdacityTouchUpInsided(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            self.centerMapOnLocation(self.initialLocation)
        })
    }
    
    @IBAction func didTapRefreshTouchUpInside(sender: AnyObject) {
       
    }
    @IBAction func didTapPinTouchUpInside(sender: AnyObject) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Helper function: construct an NSLocalizedError from an error string */
    func errorFromString(string: String) -> NSError? {
        
        return NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(string)"])
        
    }

}

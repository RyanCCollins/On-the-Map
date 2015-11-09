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
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 1000
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let loginViewController = UIViewController() as! LoginViewController
        presentViewController(loginViewController, animated: true, completion: {
            
        })
        /* Get shared session */
        
    }
    
    override func viewWillAppear(animated: Bool) {
        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()
    }
    
    func loadMapViewWithParseData() {
        if let locations = ParseClient.sharedInstance().studentInfoArray {
            
//            addPinsToMapForStudents(locations)
            
        } else {
            
            /* alert user to failure */
            
        }
    }
    
//    func addPinsToMapForStudents(studentLocations: [StudentLocationData]?) {
//        
//        var mapAnnotations = [MKAnnotation]()
//        
//        if let studentLocations = studentLocations {
//            
//            for location in studentLocations {
//                
//                /* initialize objects for map */
//                let firstName = location.First
//                let lastName = location.Last
//                let GEODescriptor = location.GEODescriptor
//                let mediaURL = location.MediaUrl
//                
//                let latitude = CLLocationDegrees(location.Latitude)
//                let longitude = CLLocationDegrees(location.Longitude)
//                let mapAnnotation = MKAnnotation()
//                mapAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                mapAnnotation.title = "\(firstName) \(lastName)"
//                mapAnnotation.subtitle = mediaURL
//                
//                mapAnnotations.append(mapAnnotation)
//                
//            }
//            updateMapPointsAsync(mapAnnotations)
//            
//        }
//        
//    }
//    
//    func updateMapPointsAsync(annotations: [MKAnnotation]){
//        dispatch_async(dispatch_get_main_queue(), {
//            for annotation in annotations {
//                self.studentLocationMapView.addAnnotation(annotation)
//            }
//        })
//    }
//    
//    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
//        let region = MKCoordinateRegionMakeWithDistance(userLocation, regionRadius, regionRadius)
//        mapView.setRegion(region, animated: true)
//    }
//    
//    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
//        
//    }
//    
//    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        if control == view.rightCalloutAccessoryView {
//            
//            let appDelegate = UIApplication.sharedApplication()
//            appDelegate.openURL(NSURL(string: view.))
//        }
//    }
//    
//    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        let pin = "pin"
//        
//        var pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pin) as? MKPinAnnotationView
//        
//        pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pin)
//        pinAnnotationView?.pinColor = .Green
//        pinAnnotationView?.pinColor = .Purple
//        pinAnnotationView?.rightCalloutAccessoryView = UIButton(type: .InfoLight)
//        
//        return pinAnnotationView
//        
//    }
    
    
    @IBAction func didTapRefreshTouchUpInside(sender: AnyObject) {
    }
    @IBAction func didTapPinTouchUpInside(sender: AnyObject) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}

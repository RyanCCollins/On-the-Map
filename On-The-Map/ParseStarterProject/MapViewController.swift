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
import Foundation

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var studentLocationMapView: MKMapView!
    let initialLocation = CLLocation(latitude: 37.399872, longitude: -122.108296)
    let regionRadius: CLLocationDistance = 1000
    let hud = MBProgressHUD()
    
    /* MARK -: Lifecycle methods */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get shared session to be uses later */
        ParseClient.sharedInstance()
        
        studentLocationMapView.delegate = self

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let locations = ParseClient.sharedInstance().studentData {
            addPinsToMapForStudents(locations)
        } else {

            didTapRefresh(self)
        }
    }
    
    /* Refresh the view by getting data from parse */
    @IBAction func didTapRefresh(sender: AnyObject) {
        
        /* Call progress indicator to show until callback */
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading Data..."
        view.alpha = 0.4
        
        /* remove annotations and add new ones */
        self.studentLocationMapView.removeAnnotations(self.studentLocationMapView.annotations)
        
        dispatch_async(GlobalUtilityQueue, {
            
            ParseClient.sharedInstance().getDataFromParse({success, results, error in

                if success {
                    
                    /* Add pins to map for students  */
                    dispatch_async(GlobalMainQueue, {
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        self.view.alpha = 1.0
                        self.addPinsToMapForStudents(ParseClient.sharedInstance().studentData)
                        
                    })
                    
                  /* Alert to error if network connection fails */
                } else if (error != nil) {
                    
                    dispatch_async(GlobalMainQueue, {
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        self.view.alpha = 1.0
                        self.alertController(withTitles: ["Ok, Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in
                                self.didTapRefresh(self)
                        }])
                        
                    })
                    
                }
                
            })

            
        })
 
    }
    
    /* Using the StudentInformation Struct, load pins in the map for students */
    func addPinsToMapForStudents(studentLocations: [StudentInformation]?) {
        
        var annotations = [MKPointAnnotation]()
        
        if let studentLocations = studentLocations {

            for location in studentLocations {
                
                /* initialize objects for map */
                let firstName = location.First
                let lastName = location.Last
                let mediaURL = location.MediaUrl
                
                let latitude = CLLocationDegrees(location.Latitude)
                let longitude = CLLocationDegrees(location.Longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL
                
                
                annotations.append(annotation)
                
            }

            self.studentLocationMapView.addAnnotations(annotations)
        }
        
    }
    
    /* Zoom in on Udacity headquarters */
    @IBAction func didTapUdacityTouchUpInsided(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            
            self.centerMapOnLocation(self.initialLocation)
            
        })
    }

}

/* MARK: Map view delegate methods */
extension MapViewController {

    /* Handle taps on annotations */
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            let appDelegate = UIApplication.sharedApplication()
            
            if let urlString = view.annotation?.subtitle! {
                
                if let url = NSURL(string: urlString) {
                    
                    appDelegate.openURL(url)
                    
                /* If unable to load url, try adding http to it */
                } else if let url = NSURL(string: "http://\(urlString)") {
                    appDelegate.openURL(url)
                
                } else {
                    
                    alertController(withTitles: ["Ok"], message: "Sorry, but the URL you selected is not valid.", callbackHandler: [nil])
                    
                }
                
            }
        }
    }
    
    
    
    /* create a mapView indicator */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pin = "pin"
        
        var pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pin)
        if pinAnnotationView  == nil {
            pinAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: pin)
            pinAnnotationView?.canShowCallout = true
            
            /* Create pin annotation with custom image */
            pinAnnotationView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            pinAnnotationView?.image = UIImage(named: "udacity-logo-pin")
            
        } else {
            
            pinAnnotationView?.annotation = annotation
            
        }
        
        return pinAnnotationView
        
    }
    
    /* Center on location (Udacity headquarters) on the map */
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 4.0, regionRadius * 4.0)
        studentLocationMapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    
    /* Find current location and zoom in */
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let center = CLLocationCoordinate2D(latitude: (userLocation.location?.coordinate.latitude)!, longitude: (userLocation.location?.coordinate.longitude)!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01))
        mapView.setRegion(region, animated: true)
    }
}

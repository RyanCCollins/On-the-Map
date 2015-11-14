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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get shared session */
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
    
    @IBAction func didTapRefresh(sender: AnyObject) {
        
        /* call HUD To show until callback */
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Reloading..."
        
        /* remove annotations and add new ones */
        studentLocationMapView.removeAnnotations(studentLocationMapView.annotations)
        refreshDataFromParse({
            
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
        })
        
        
    }
    
    /* Refresh Parse data and callback when complete to hide progress */
    func refreshDataFromParse(completionCallback: ()->Void) {

        self.loadMapViewWithParseData({success, error in
            
            if success {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.addPinsToMapForStudents(ParseClient.sharedInstance().studentData)
                })
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: {Void in
                        self.didTapRefresh(self)
                    })
                    
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                    
                    self.alertUserWithWithActions("Error loading", message: "Sorry, but there was an error loading the data from the network", actions: [retryAction, dismissAction])
                    
                })
                
            }
            
        })
        
        completionCallback()

    }
    
    /* add parse data to map if first time logging in, get the data, if not, get the shared instance of student data */
    func loadMapViewWithParseData(completionHandler: (success: Bool, error: NSError?)-> Void) {
        
        ParseClient.sharedInstance().getDataFromParse({success, results, error in
            
            if success {
                
                completionHandler(success: true, error: nil)
                
                
            } else {
                
                completionHandler(success: false, error: self.errorFromString("Failed to load data in: loadMapWithParseData"))
            }
        })
    
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

            self.studentLocationMapView.addAnnotations(annotations)
        }
        
    }

    
    /* Center on location of map */
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        studentLocationMapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    /* MARK: Map view delegate methods */
    
    /* Find current location and zoom in */
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let center = CLLocationCoordinate2D(latitude: (userLocation.location?.coordinate.latitude)!, longitude: (userLocation.location?.coordinate.longitude)!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            let appDelegate = UIApplication.sharedApplication()
            
            if let urlString = view.annotation?.subtitle! {
                
                if let url = NSURL(string: urlString) {
                    
                    appDelegate.openURL(url)
                    
                } else {
                    
                    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alertUserWithWithActions("Not a valid URL", message: "Sorry, but the URL you selected is not valid.", actions: [okAction])
                    
                }
                
            }
        }
    }
    
    
    
    /* create a mapView indicator */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        

        if (annotation is MKUserLocation) {
            
            return nil
        }
        
        
        let pin = "pin"
        
        var pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pin)
        if pinAnnotationView  == nil {
        pinAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: pin)
        pinAnnotationView?.canShowCallout = true
//        pinAnnotationView?.pinTintColor = UIColor.flatMintColor()
        pinAnnotationView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        pinAnnotationView?.image = UIImage(named: "Udacity_Logo")
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

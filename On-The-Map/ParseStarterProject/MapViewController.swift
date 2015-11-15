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
        hud.labelText = "Loading Data..."
        
        /* remove annotations and add new ones */
        studentLocationMapView.removeAnnotations(studentLocationMapView.annotations)
        refreshDataFromParse({
            
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
        })
        
        
    }
    
    /* Refresh Parse data and callback when complete to hide progress */
    func refreshDataFromParse(completionCallback: ()->Void) {
        
        ParseClient.sharedInstance().getDataFromParse({success, results, error in
            
            if success {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.addPinsToMapForStudents(ParseClient.sharedInstance().studentData)
                    completionCallback()
                })
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.alertController(withTitles: ["Ok, Retry"], message: "Sorry but there was an issue loading data from the network.", callbackHandler: [nil, {Void in
                            completionCallback()
                    }])

                })
                
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
                    
                    alertController(withTitles: ["Ok"], message: "Sorry, but the URL you selected is not valid.", callbackHandler: [nil])
                    
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

        pinAnnotationView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        pinAnnotationView?.image = UIImage(named: "udacity-logo-pin")
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

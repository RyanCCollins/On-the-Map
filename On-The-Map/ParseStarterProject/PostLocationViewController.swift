//
//  PostLocationViewController.swift
//  On The Map
//
//  Created by Ryan Collins on 11/10/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD

class PostLocationViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var locationTextField: JiroTextField!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var postLocationViewContainer: UIView!
    @IBOutlet weak var linkTextField: JiroTextField!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var linkViewContainer: UIView!
    let coordinateSpan = MKCoordinateSpan()
    let regionRadius: CLLocationDistance = 1000
    
    var isSubmittingURL = false
    var locationString: String? = nil
    var mediaURL: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureDisplay(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    @IBAction func didTapCancelButtonTouchUpInside(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {
            /* ToDo refresh view */
        })
    }
    
    
    @IBAction func userDidTapSubmitLocationUpInside(sender: AnyObject) {
        if isSubmittingURL == false {
            
            isSubmittingURL = true
            
            
            
            if let location = locationTextField.text {

                locationString = location
                verifyLocation(locationString!)
                
            } else {
                
                /* alert user of bad string */
                
            }
            
        } else {
            
            if let mediaURL = linkTextField.text {
            
            let parameters = ParseClient.sharedInstance().makeDictionaryForPostLocation(mediaURL, mapString: locationString!)
                
                ParseClient.sharedInstance().postDataToParse(parameters, completionHandler: {success, error in
                    
                    if let error = error {
                        
                        let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: nil)
                        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: {Void in
                            self.didTapRefreshTouchUpInside(self)
                        })
                        
                        self.alertUserWithWithActions("Something went wrong", message: "An error occured while submitting your location, please retry or go back to the Map.", actions: [retryAction, dismissAction])
                        
                    } else {
                        
                        /* refresh and present mapViewController */
                        self.didTapRefreshTouchUpInside(self)
                        
                    }
                    
                })
                
            } else {
                
                /*
                alertUser */
            }
            
        }
    }
    
    
    func verifyLocation(location: String) {
        let geocoder = CLGeocoder()
        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {

            geocoder.geocodeAddressString(location, completionHandler: { placemarks, error in
                
                if let placemark = placemarks![0] as? CLPlacemark {
                    
                    self.configureDisplay(false)
                    
                    UdaciousClient.sharedInstance().latitude = CLLocationDegrees(placemark.location!.coordinate.latitude)
                    UdaciousClient.sharedInstance().longitude = CLLocationDegrees(placemark.location!.coordinate.longitude)
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude)
                    
                    
                   let coordinateRegion = MKCoordinateRegionMakeWithDistance(placemark.location!.coordinate, self.regionRadius * 2.0, self.regionRadius * 2.0)
                    
                    self.mapView.setRegion(coordinateRegion, animated: true)
                    
                    self.mapView.addAnnotation(annotation)
                    
                } else {
                    
                    let tryAgain = UIAlertAction(title: "Try again", style: .Default, handler: nil)
                    
                    self.alertUserWithWithActions("Could not verify location", message: "Sorry, but we could not verify your location. Please try again", actions: [tryAgain])
                    
                }
                
            })
        
        dispatch_async(dispatch_get_main_queue(), {
            
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        })
        })
        
    }
    
    /* configure display for reset */
    func configureDisplay(reset: Bool) {
        
        
        mapView.hidden = reset
        linkTextField.hidden = reset
        linkTextField.hidden = reset
        
        locationTextField.hidden = !reset
        headerLabel.hidden = !reset
        helpLabel.hidden = !reset
        linkViewContainer.hidden = !reset
        
        
    }
    
}

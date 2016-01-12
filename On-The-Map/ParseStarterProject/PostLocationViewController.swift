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
import Foundation

class PostLocationViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var locationTextField: KaedeTextField!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
  
    @IBOutlet weak var linkTextField: KaedeTextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topViewContainer: UIView!
    
    let coordinateSpan = MKCoordinateSpan()
    let regionRadius: CLLocationDistance = 1000
    
    var isSubmittingURL = false
    var locationStringToPost: String? = nil
    var mediaURLToPost: String? = nil
    
    /* MARK: Lifecycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkTextField.delegate = self
        locationTextField.delegate = self
        
        mapView.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureDisplay(true)
        queryParseForResults()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    /* Run query in utility thread to find results for user.  If found, alert to found results in global queue and ask if they would like to update thir location.  If not, carry on. */
    func queryParseForResults() {
        
        /* Show activity while loading */
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        dispatch_async(GlobalUserInteractiveQueue, {
            
            hud.labelText = "Loading..."
            hud.show(true)

        })

        /* Query parse for a match of most recent submission */
        ParseClient.sharedInstance().queryParseDataForLastSubmission({success, results, error in
            
            if success {
                
                dispatch_async(GlobalMainQueue, {
                    hud.hide(true)
                    /* Show alert controller showing that you're about to overwrite the recently submitted location */
                    self.alertController(withTitles: ["OK", "Cancel"], message: "You have already submitted your location.  Press OK to update it, or Cancel to go back.", callbackHandler: [nil, {Void in
                        self.didTapCancelButtonTouchUpInside(self)
                        }])
                    
                    /* Update UI to show last submitted location */
                    self.locationStringToPost = results!.GEODescriptor
                    self.mediaURLToPost = results!.MediaUrl
                    self.linkTextField.text = self.mediaURLToPost
                    self.locationTextField.text = self.locationStringToPost
                    
                })
                
                
            } else {
                dispatch_async(GlobalMainQueue, {
                    
                    hud.hide(true)
                })
                
            }
            
            
        })

    }
    
    @IBAction func didTapCancelButtonTouchUpInside(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* If user is submitting a valid location, show on the map */
    @IBAction func userDidTapSubmitLocationUpInside(sender: AnyObject) {
        
        /* If user is submitting a location and it is not nil, verify the location */
        if isSubmittingURL == false {
            
            guard locationTextField.text != nil else {
                alertController(withTitles: ["OK"], message: GlobalErrors.MissingData.localizedDescription, callbackHandler: [{Void in return}])
                return
            }
            
            /* Show progress while verifying location */
            dispatch_async(GlobalMainQueue, {
                
                let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                hud.labelText = "Locating..."
                hud.show(true)
                self.view.alpha = 0.4
                
            })
            
            /* Verify the location and get rid of activity indicator when complete */
            self.verifyLocation(self.locationTextField.text!, completionCallback: {success, error in
                
                dispatch_async(GlobalMainQueue, {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.view.alpha = 1.0
                })
                if error != nil {
                    
                    /* Alert if unable to geocode location */
                    self.alertController(withTitles: ["Ok"], message: error!.localizedDescription, callbackHandler: [nil])
                    
                }
            })

        } else {
            /* Once location is verified, go ahead and submit the location and URL as long as URL is valid */
            guard linkTextField.text != nil else {
                alertController(withTitles: ["OK"], message: GlobalErrors.MissingData.localizedDescription, callbackHandler: [nil])
                return
            }
            mediaURLToPost = linkTextField.text
            
            /* GUARD : Do we have a valid URL? */
            guard let _ = NSURL(string: mediaURLToPost!) else {
                alertController(withTitles: ["Try Again"], message: GlobalErrors.InvalidURL.localizedDescription, callbackHandler: [{Void in
                    self.mediaURLToPost = nil
                    self.isSubmittingURL = true
                    }])
                return
                
            }
            
            postLocationAndURLToParse()
        
        }
    }
    
    
    /* Post location and URL to Parse */
    func postLocationAndURLToParse() {
        
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Posting..."
        self.view.alpha = 0.4
        
        /* Show progress while submitting data */
        dispatch_async(GlobalMainQueue, {
            hud.show(true)
        })
        
        /* Add or update data to parse in background while hud is shown in user initiated queue */
        
        let JSONBody = ParseClient.sharedInstance().makeDictionaryForPostLocation(mediaURLToPost!, mapString: locationStringToPost!)
        

        ParseClient.sharedInstance().postDataToParse(JSONBody, completionHandler: {success, error in
            
            if success {
                
                /* If successful, hide progress and dismiss view */
                dispatch_async(GlobalMainQueue, {
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.view.alpha = 1.0
                    ParseClient.sharedInstance().studentData  = nil
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                })
                
                
            } else {
                
                /* Hide the activity indicator and show alert */
                dispatch_async(GlobalMainQueue, {
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.view.alpha = 1.0
                    self.alertController(withTitles: ["Cancel", "Try Again"], message: (error?.localizedDescription)!, callbackHandler: [{Void in
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                        }, {Void in
                            
                            self.postLocationAndURLToParse()
                            
                    }])
                    
                })
                
            }
        
        })
        
    }
    
    /* Verify that the location is geocoded properly */
    func verifyLocation(locationString: String, completionCallback: (success: Bool, error: NSError?)-> Void){
        let geocoder = CLGeocoder()
        
        dispatch_async(GlobalUtilityQueue, {

            geocoder.geocodeAddressString(locationString, completionHandler: { placemarks, error in
                
                if placemarks != nil {
                    
                    self.locationStringToPost = locationString
                    

                    let selectedPlacemark = placemarks![0]

                    self.isSubmittingURL = true
                    self.configureDisplay(false)
                    
                    UdaciousClient.sharedInstance().latitude = CLLocationDegrees(selectedPlacemark.location!.coordinate.latitude)
                    UdaciousClient.sharedInstance().longitude = CLLocationDegrees(selectedPlacemark.location!.coordinate.longitude)
                    
                    
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: selectedPlacemark.location!.coordinate.latitude, longitude: selectedPlacemark.location!.coordinate.longitude)
                    
                    
                   let coordinateRegion = MKCoordinateRegionMakeWithDistance(selectedPlacemark.location!.coordinate, self.regionRadius * 2.0, self.regionRadius * 2.0)
                    
                    self.mapView.setRegion(coordinateRegion, animated: true)
                    
                    self.mapView.addAnnotation(annotation)
                    
                    completionCallback(success: true, error: nil)
                    
                } else {
                    
                    completionCallback(success: false, error: GlobalErrors.GEOCode)
                
                }
                
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
        
        if !reset {
            topViewContainer.backgroundColor = UIColor.flatBlueColor()
        }
    }
    
    /* MARK: Mapkit delegate method: */
    
    /* create a mapView indicator */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if (annotation is MKUserLocation) {
            
            return nil
        }
        
        
        let pin = "pin"
        
        var pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pin) as? MKPinAnnotationView
        if pinAnnotationView  == nil {
            pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pin)
            if #available(iOS 9.0, *) {
                pinAnnotationView?.pinTintColor = UIColor.flatMintColor()
            } else {
                pinAnnotationView?.pinColor = .Green
            }
            
        } else {
            pinAnnotationView?.annotation = annotation
        }
        
        return pinAnnotationView
        
    }

}

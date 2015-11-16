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
    var locationString: String? = nil
    var mediaURL: String? = nil
    var ObjectId: String? = nil
    
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
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading..."
        
        dispatch_async(GlobalUserInteractiveQueue, {
            hud.show(true)
        })
        

        ParseClient.sharedInstance().queryParseDataForObjectId({success, results, error in
            
            if success {
                
                dispatch_async(GlobalMainQueue, {
                    self.alertController(withTitles: ["OK", "Cancel"], message: "You have already submitted your location.  Press OK to update it, or Cancel to go back.", callbackHandler: [nil, {Void in
                            self.didTapCancelButtonTouchUpInside(self)
                        }])
                    self.locationString = results!.GEODescriptor
                    self.mediaURL = results!.MediaUrl
                    self.ObjectId = results!.ObjectID
                    self.linkTextField.text = self.mediaURL
                    self.locationTextField.text = self.locationString
                    hud.hide(true)
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
        
        if isSubmittingURL == false {
            
            
            guard locationTextField.text != nil else {
                alertController(withTitles: ["OK"], message: GlobalErrors.MissingData.localizedDescription, callbackHandler: [{Void in return}])
                return
            }
            
            /* Show progress while verifying location */
            
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.labelText = "Locating..."
            
            self.verifyLocation(self.locationTextField.text!, completionCallback: {success, error in
                dispatch_async(GlobalMainQueue, {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                })
                if error != nil {
            
                    self.alertController(withTitles: ["Ok"], message: error!.localizedDescription, callbackHandler: [nil])

                }
            })

        } else {
            
            guard linkTextField.text != nil else {
                alertController(withTitles: ["OK"], message: GlobalErrors.MissingData.localizedDescription, callbackHandler: [nil])
                return
            }
            mediaURL = linkTextField.text
            
            guard let _ = NSURL(string: mediaURL!) else {
                alertController(withTitles: ["Try Again"], message: GlobalErrors.InvalidURL.localizedDescription, callbackHandler: [{Void in
                        self.mediaURL = nil
                        self.isSubmittingURL = true
                    }])
                return
                
            }
            
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            hud.labelText = "Posting..."
            
            /* Show progress while submitting data */
            dispatch_async(GlobalUserInitiatedQueue, {
                
                hud.show(true)
            })
            
        /* Add or update data to parse in background while hud is shown in user initiated queue */

            self.updateOrAddNewDataToParse(self.mediaURL!, mapString: self.locationString!, completionCallback: {success, error in
                
                if error != nil {
                    
                    self.alertController(withTitles: ["Cancel", "Try Again"], message: (error?.localizedDescription)!, callbackHandler: [{Void in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }, nil])
                    
                } else {
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    ParseClient.sharedInstance().studentData  = nil
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                }

            })
            

        }
    }
    

    
    
    func verifyLocation(locationString: String, completionCallback: (success: Bool, error: NSError?)-> Void){
        let geocoder = CLGeocoder()
        
        dispatch_async(GlobalUtilityQueue, {

            geocoder.geocodeAddressString(locationString, completionHandler: { placemarks, error in
                
                if placemarks != nil {
                    
                    self.locationString = locationString
                    

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
    
    func updateOrAddNewDataToParse(mediaURL: String, mapString: String, completionCallback: ((success: Bool, error: NSError?)-> Void)) {
        
        let JSONBody = ParseClient.sharedInstance().makeDictionaryForPostLocation(mediaURL, mapString: self.locationString!)
        
        if ObjectId != nil {
                
            ParseClient.sharedInstance().updateLocationForObjectId(self.ObjectId!, JSONBody: JSONBody, completionHandler: {success, error in
                
                if error != nil {
                    
                    completionCallback(success: false, error: error)

                } else {
                    
                    completionCallback(success: true, error: nil)
                    
                }
                
            })

        } else {
            
            ParseClient.sharedInstance().postDataToParse(JSONBody, completionHandler: {success, error in
                
                if error != nil {
                    
                    completionCallback(success: false, error: error)
                    
                } else {
                    
                    completionCallback(success: true, error: nil)
                    
                }
                
            })
            
        }

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
            pinAnnotationView?.pinTintColor = UIColor.flatMintColor()
            
        } else {
            pinAnnotationView?.annotation = annotation
        }
        
        return pinAnnotationView
        
    }

}

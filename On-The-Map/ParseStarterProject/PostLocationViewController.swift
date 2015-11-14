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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkTextField.delegate = self
        locationTextField.delegate = self
        
        mapView.delegate = self
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* If user is submitting a valid location, show on the map */
    @IBAction func userDidTapSubmitLocationUpInside(sender: AnyObject) {
        
        if isSubmittingURL == false {
            
            
            guard locationTextField.text != nil else {
    
                return
                
            }
            
            /* Show progress while verifying location */
            
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.labelText = "Locating..."
            
            self.verifyLocation(self.locationTextField.text!, completionCallback: {
                dispatch_async(dispatch_get_main_queue(), {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                })
            })

        } else {
            
            if linkTextField.text != nil {
                mediaURL = linkTextField.text
                
                guard let _ = NSURL(string: mediaURL!) else {
                    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    
                    alertUserWithWithActions("Not a valid URL", message: "Sorry, but the url you provided is not valid.  Please share a new link.", actions: [okAction])
                    return
                    
                }
                
                /* Show progress while submitting data */
                let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                hud.labelText = "Posting..."
                

                self.updateOrAddNewDataToParse(mediaURL!, mapString: self.locationString!, completionCallback: {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                })

                
                
            } else {
                
                let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alertUserWithWithActions("Something's missing", message: "Please enter a valid string when submitting the URL", actions: [okAction])
                
            }
            
        }
    }
    
    func updateOrAddNewDataToParse(mediaURL: String, mapString: String, completionCallback: (()-> Void)?) {
        
        let JSONBody = ParseClient.sharedInstance().makeDictionaryForPostLocation(mediaURL, mapString: self.locationString!)
        ParseClient.sharedInstance().postDataToParse(JSONBody, completionHandler: {success, error in
            
            if success {
                    
                ParseClient.sharedInstance().studentData = nil
                self.dismissViewControllerAnimated(true, completion: nil)
                    
            } else {
                    
                let tryAgain = UIAlertAction(title: "Try again", style: .Default, handler: {Void in
                    
                    self.updateOrAddNewDataToParse(mediaURL, mapString: self.locationString!, completionCallback: nil)
                    
                })
                
                let dismissAction = UIAlertAction(title: "Leave", style: .Destructive, handler: {Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
                self.alertUserWithWithActions("Something went wrong", message: "An error occured while updating your location.  Submit as new or get out of here?", actions: [tryAgain, dismissAction])
                
            }
            
            completionCallback!()

        })
    }
    
    
    func verifyLocation(locationString: String, completionCallback: ()-> Void){
        let geocoder = CLGeocoder()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {

            geocoder.geocodeAddressString(locationString, completionHandler: { placemarks, error in
                
                if placemarks != nil {
                    
                    self.locationString = locationString
                    
                    var selectedPlacemark: CLPlacemark?
                    
                    if placemarks!.count > 1 {
                        print("More than one")
                        self.callAlertControllerForMultiplePlacemarks(placemarks!, completionClosure: { placemark in
                            selectedPlacemark = placemark
                        })
                        
                    } else {
                        
                        selectedPlacemark = placemarks![0]
                        
                    }

                    
                    self.isSubmittingURL = true
                    self.configureDisplay(false)
                    
                    UdaciousClient.sharedInstance().latitude = CLLocationDegrees(selectedPlacemark!.location!.coordinate.latitude)
                    UdaciousClient.sharedInstance().longitude = CLLocationDegrees(selectedPlacemark!.location!.coordinate.longitude)
                    
                    
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: selectedPlacemark!.location!.coordinate.latitude, longitude: selectedPlacemark!.location!.coordinate.longitude)
                    
                    
                   let coordinateRegion = MKCoordinateRegionMakeWithDistance(selectedPlacemark!.location!.coordinate, self.regionRadius * 2.0, self.regionRadius * 2.0)
                    
                    self.mapView.setRegion(coordinateRegion, animated: true)
                    
                    self.mapView.addAnnotation(annotation)
                    
                } else {
                    
                    let tryAgain = UIAlertAction(title: "Try again", style: .Default, handler: nil)
                
                    self.alertUserWithWithActions("Could not verify location", message: "Sorry, but we could not verify your location. Please try again", actions: [tryAgain])
                
                }
                
            })
            
            completionCallback()

        })
        
    }
    
    
    /* Present the user with several options to select a placemark if there are more than one options (fancy closures, eh :D ) */
    func callAlertControllerForMultiplePlacemarks(placemarks: [CLPlacemark], completionClosure: (placemark: CLPlacemark) -> ()){
        
        let ac = UIAlertController(title: "Multiple Matches", message: "More than one location was found.  Please select the one you are looking for or be more specific", preferredStyle: .ActionSheet)
        
        var selectedIndex: Int?
        
        let closure = { (index: Int) in
            { (action: UIAlertAction) -> Void in
                selectedIndex = index
            }
        }
        
        for placemark in placemarks.enumerate() {
            
            if placemark.index < 3 {
                let action = UIAlertAction(title: placemark.1.description, style: .Default, handler: closure(placemark.index))
                ac.addAction(action)
                
            }
        }
        
        ac.presentViewController(ac, animated: true, completion: {
            completionClosure(placemark: placemarks[selectedIndex!])
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
            pinAnnotationView?.pinTintColor = UIColor.flatMintColor()
            
        } else {
            pinAnnotationView?.annotation = annotation
        }
        
        return pinAnnotationView
        
    }

}

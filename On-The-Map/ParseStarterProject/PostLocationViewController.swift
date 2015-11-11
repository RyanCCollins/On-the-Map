//
//  PostLocationViewController.swift
//  On The Map
//
//  Created by Ryan Collins on 11/10/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class PostLocationViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var locationTextField: JiroTextField!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
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
            
        })
    }

    @IBAction func userDidTapSubmitUpInside(sender: AnyObject) {
        if ((sender.titleLabel!!.text?.containsString("Location")) != nil) {
            
            if let location = locationTextField.text {

                locationString = location
            } else {
                
                /* alert user of bad string */
                
            }
            
        } else {
            
            if let mediaURL = locationTextField.text {
            
            let parameters = ParseClient.sharedInstance().makeDictionaryForPostLocation(mediaURL, mapString: locationString!)
                
                ParseClient.sharedInstance().postDataToParse(parameters, completionHandler: {success, error in
                    
                    if let error = error {
                        
                        /* todo alert user  */
                    } else {
                        
                        self.refreshDataFromParse()
                        
                    }
                    
                })
                
            } else {
                
                /*
                alertUser */
            }
            
        }
    }
    
    /* configure display for reset */
    func configureDisplay(reset: Bool) {
        if reset {
            
            headerLabel.text = "Where are you studying today?"
            helpLabel.text = "Enter your location above and press submit to find on the map."
            submitButton.titleLabel?.text = "Submit Location"
            locationTextField.placeholder = "Enter your location"
            locationTextField.text = nil
            
        } else {
            
            headerLabel.text = "What are you studying?"
            helpLabel.text = "Enter a link to what you're studying above and press submit."
            submitButton.titleLabel?.text = "Submit Link"
            locationTextField.placeholder = "Enter a link here"
            locationTextField.text = nil
            
        }
    }
    
}

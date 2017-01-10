//
//  CurrentLocationViewController.swift
//  TrackLocation
//
//  Created by iUS on 11/9/16.
//  Copyright © 2016 ayush. All rights reserved.//
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController,CLLocationManagerDelegate {
 
//MARK: Globals
    
    var location : CLLocation?
    var locationManager = CLLocationManager()
    var updatingLocation = false
    var lastLocationError : Error?
    
    let geocoder = CLGeocoder()
    var placemark : CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError : Error?
    
    var timer : Timer?
    
    var managedObjectContext : NSManagedObjectContext!
    
    
    
//MARK: Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getLocationButton: UIButton!

//MARK: Actions
    @IBAction func getLocation(_ sender: UIButton) {
        
        placemark = nil
        lastGeocodingError = nil
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .denied || authStatus == .restricted {
            showlocationServicesDisabledAlert()
            /*
            -Important
            The return statement below takes you out of from getLocation(_:_) action method
            */
            return
        }
        
        //.notDetermined means the app has not asked for permission yet
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            startLocationManager()
        }
        updateLabels()
        configureGetButton()
    }
    
//MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
    }
    
    
//MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TagLocation"{
        
        let navigationController = segue.destination as! UINavigationController
            
        let locationDetailVC = navigationController.topViewController as! LocationDetailViewController
            
        locationDetailVC.placemark = placemark
        locationDetailVC.coordinate = location!.coordinate
        locationDetailVC.managedObjectContext = managedObjectContext
            
        }
        
        
    }
    
//MARK: - CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DidFailWithError : \(error)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue{
            return
        }
        
        lastLocationError = error
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations : \(newLocation)")
        
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
       
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        
        //This calculates the distance between the new reading and the previous reading, if there was one. We can use this distance to measure if our location updates are still improving.
        //If there was no previous reading, then the distance is DBL_MAX. That is a built-in constant that represents the maximum value that a floating-point number can have.
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distance(from: location)
        }

        
        
        //  So if this is the very first location reading (location is nil) or the new location is more accurate than the previous reading, you continue to step 4. Otherwise you ignore this location update.
        // If the first one is true (location is nil), it will ignore the second condition. That’s called short circuiting.
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            // 4 It clears out any previous error if there was one and stores the new CLLocation object into the location variable.
            lastLocationError = nil
            location = newLocation
            updateLabels()
            //  If the new location’s accuracy is equal to or better than the desired accuracy, you can call it a day and stop asking the location manager for updates.
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                configureGetButton()
                
                
                
                //Simply by setting performingReverseGeocoding to false, you always force the geocoding to be done for this final coordinate.
                if distance > 0 {
                        performingReverseGeocoding = false
                    }
                
            }
            
           //Then you start the geocoder.
            if !performingReverseGeocoding{
                print("*** Going to Geocode")
                
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: { placemarks , error in
                    //Closures are said to capture all the variables they use and self is one of them. You may immediately forget about that; just know that Swift requires that all captured variables are explicitly mentioned.
                    print("*** Found placemarks \(placemarks) , error : \(error) ")
                    self.lastGeocodingError = error
                    
                    /*
                    if error == nil {
                     if let p = placemarks {
                        if !p.isEmpty {
                    */
                    if error == nil, let p = placemarks, !p.isEmpty {
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        
        }else if distance < 1 {
            //If the coordinate from this reading is not significantly different from the previous reading and it has been more than 10 seconds since you’ve received that original reading, then it’s a good point to hang up your hat and stop.
            
            //The distance between subsequent readings is never exactly 0. It may be something like 0.0017632. Rather than checking for equals to 0, it’s better to check for less than a certain distance, in this case one meter.
            
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)

                if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
                }
        }

    }//end of didUpdateLocations func
    
    
//MARK: - Convenience Methods 
    
    func showlocationServicesDisabledAlert(){
        
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func updateLabels(){
        
        if let location = location {
            latitudeLabel.text = String(format: "%.8f",location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            messageLabel.text = ""
            tagButton.isHidden = false
            
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            }else{
                addressLabel.text = "No Address Found"
            }
        
        }else{
            
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            tagButton.isHidden = true
            
            
            let statusMessage: String
            if let error = lastLocationError as? NSError {
                if error.domain == kCLErrorDomain &&
                    error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            
            messageLabel.text = statusMessage
            
        }
    
    }
    
    func startLocationManager(){
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            //set up a timer object that sends the “didTimeOut” message to self after 60 seconds; didTimeOut is the name of a method.
            timer = Timer.scheduledTimer(timeInterval: 60, target: self,
                                         selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    
    func stopLocationManager(){
        
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            //You have to cancel the timer in case the location manager is stopped before the time-out fires. This happens when an accurate enough location is found within(inside of) one minute after starting, or when the user tapped the Stop button.
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func configureGetButton() {
        if updatingLocation {
            getLocationButton.setTitle("Stop", for: .normal)
        } else {
            getLocationButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    func string(from placemark: CLPlacemark) -> String {
        // 1
        var line1 = ""
        // 2
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        // 3
        if let s = placemark.thoroughfare {
            line1 += s }
        // 4
        var line2 = ""
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s }
        // 5
        return line1 + "\n" + line2
    }
    
    
    //didTimeOut() is always called after one minute, whether you’ve obtained a valid location or not – unless stopLocationManager() cancels the timer first.
    func didTimeOut() {
        print("*** Time out")
        
        
        //If after that one minute there still is no valid location, you stop the location manager, create your own error code, and update the screen.
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain",
                                        code: 1, userInfo: nil)
            updateLabels()
            configureGetButton()
        }
    }
    
    
}

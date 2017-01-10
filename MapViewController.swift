//
//  MapViewController.swift
//  TrackLocation
//
//  Created by iUS on 11/9/16.
//  Copyright © 2016 ayush. All rights reserved.//
//

import UIKit
import MapKit
import CoreData


//make sure you connected the view controller as the delegate of the map view in the storyboard
class MapViewController: UIViewController{
    
    
    @IBOutlet weak var mapView: MKMapView!
    var locations = [Location]()
    
    /*
    *** Using notifications of Core Data ***
    -As soon as managedObjectContext is given a value – which happens in AppDelegate during app startup – the didSet block tells the NotificationCenter to add an observer for the NSManagedObjectContextObjectsDidChange notification.
    -This notification with the very long name is sent out by the managedObjectContext whenever the data store changes. 
    
    *** Whats happening inside the closure ? ***
    -You just call updateLocations() to fetch all the Location objects again. This throws away all the old pins and it makes new pins for all the newly fetched Location objects. Granted, it’s not a very efficient method if there are hundreds of annotation objects, but for now it gets the job done.
     -You use if self.isViewLoaded to make sure updateLocations() only gets called when the map view is loaded.Because this screen sits in a tab, the view from MapViewController does not actually get loaded from the storyboard until the user switches to the Map tab.So the view may not have been loaded yet when the user tags a new location. In that case it makes no sense to call updateLocations() – it could even crash the app because the MKMapView object doesn’t exist yet at that point!
    
    */
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NotificationCenter.default.addObserver(forName:
                Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main) { notification in
                
                if self.isViewLoaded {
                            self.updateLocations()
                    }
                }
        }//end of didSet
    }
    

// MARK: - Actions
    @IBAction func showUser() {
        
        //When you press the User button, it zooms in the map to a region that is 1000 by 1000 meters (a little more than half a mile in both directions) around the user’s position.
        let region = MKCoordinateRegionMakeWithDistance(
            mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    
    //show the region that contains all the user’s saved locations. Before you can do that, you first have to fetch those locations from the data store.
    @IBAction func showLocations() {
        
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
        
    }
    
// MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This fetches the Location objects and shows them on the map when the view loads.
        updateLocations()
        
        if !locations.isEmpty{
            showLocations()
        }
    }
    

// MARK: - Convenience Methods
    
    func updateLocations(){
        
        // Why we remove annotation?
        // The idea is that updateLocations() will be executed every time there is a change in the data store. How you’ll do that is of later concern, but the point is that when this happens the locations array may already exist and may contain Location objects. If so, you first remove the pins for these old objects with removeAnnotations().
        mapView.removeAnnotations(locations)
        
        // you’re not sorting the Location objects. The order of the Location objects in the array doesn’t really matter to the map view, only their latitude and longitude coordinates.
        let entity = Location.entity()
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        
        //You’ve seen how to handle errors with a do-try-catch block. If you’re certain that a particular method call will never fail, you can dispense with the do and catch and just write try! with an exclamation point. As with other things in Swift that have exclamation points, if it turns out that you were wrong, the app will crash without mercy.
        locations = try! managedObjectContext.fetch(fetchRequest)
        mapView.addAnnotations(locations)
        
    }
    
    
    //calculate a region and then tell the map view to zoom to that region.
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        
        switch annotations.count {
        
        //There are no annotations. You’ll center the map on the user’s current position.
        case 0:
            region = MKCoordinateRegionMakeWithDistance(
                mapView.userLocation.coordinate, 1000, 1000)
        
        //There is only one annotation. You’ll center the map on that one annotation.
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(
                annotation.coordinate, 1000, 1000)
        
        //There are two or more annotations. You’ll calculate the extent of their reach and add a little padding. See if you can make sense of those calculations. The max() function looks at two values and returns the larger of the two; min() returns the smaller; abs() always makes a number positive (absolute value).
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90,
                                                      longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90,
                                                          longitude: -180)
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude,
                                            annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude,
                                             annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude,
                                                annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: topLeftCoord.latitude -
                    (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                longitude: topLeftCoord.longitude -
                    (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            let extraSpace = 1.1
            
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoord.latitude -
                    bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude -
                    bottomRightCoord.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)
    }
    
    
    //In this case the sender will be the (i) button. That’s why the type of the sender parameter is UIButton.
    func showLocationDetails(_ sender: UIButton){
        performSegue(withIdentifier: "EditLocation", sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation"{
            
            // get the Location object to edit from the locations array, using the tag property of the sender button as the index in that array.
            let navigationController = segue.destination
                as! UINavigationController
            let controller = navigationController.topViewController
                as! LocationDetailViewController
            controller.managedObjectContext = managedObjectContext
            let button = sender as! UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
            
        }
    }
}


//
//  MapViewController+Delegate.swift
//  TrackLocation
//
//  Created by iUS on 11/9/16.
//  Copyright © 2016 ayush. All rights reserved.//
//

import MapKit
import UIKit


//This delegate is useful for creating your own annotation views
extension MapViewController: MKMapViewDelegate {

   
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // 1 - Because MKAnnotation is a protocol,there may be other objects apart from the Location object that want to be annotations on the map. An example is the blue dot that represents the user’s current location. You should leave such annotations alone, so you use the special “is” type check operator to determine whether the annotation is really a Location object. If it isn’t, you return nil to signal that you’re not making an annotation for this other kind of object.
        guard annotation is Location else {
                return nil
        }
        // 2 - This looks similar to creating a table view cell. You ask the mapview to re-use an annotation view object. If it cannot find a recyclable annotation view, then you create a new one.Note that you’re not limited to using MKPinAnnotationView for your annotations. This is the standard annotation view class, but you can also create your own MKAnnotationView subclass and make it look like anything you want. Pins are only one option.
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: identifier)
        let pinView = MKPinAnnotationView(annotation: annotation,reuseIdentifier: identifier)
        
        
        if annotationView == nil {
            
            // 3-This sets some properties to configure the look and feel of the annotationview. Previously the pins were red, but you make them green here.
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82,
            blue: 0.4, alpha: 1)
            
            
            // 4 - You create a new UIButton object that looks like a detail disclosure button (a blue circled i). You use the target-action pattern to hook up the button’s “Touch Up Inside” event with a new method showLocationDetails(), and add the button to the annotation view’s accessory view.
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self,action: #selector(showLocationDetails),for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            annotationView = pinView
        }
            
        
        if let annotationView = annotationView {
            
            annotationView.annotation = annotation
            
            // 5 - Once the annotation view is constructed and configured,you obtain a reference to that detail disclosure button again and set its tag to the index of the Location object in the locations array. That way you can find the Location object later in showLocationDetails() when the button is pressed.
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.index(of: annotation as! Location) {
                    button.tag = index
            }
        }
        
        return annotationView
        
    }

    
}


// Fixing gap issue between navigation bar and top of screen
extension MapViewController: UINavigationBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

}

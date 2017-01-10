//
//  Location+CoreDataClass.swift
//  TrackLocation
//
//  Created by iUS on 11/9/16.
//  Copyright © 2016 ayush. All rights reserved.//
//

import Foundation
import CoreData
import MapKit

@objc(Location)



public class Location: NSManagedObject , MKAnnotation {
       public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    public var subtitle: String? {
        return category
    }
    
    public var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    //Alternative method (instead of using computed properties)
    //    func title() -> String? {
    //        if locationDescription.isEmpty {
    //            return "(No Description)"
    //        } else {
    //            return locationDescription
    //        }
    //    }
    
    
    
}

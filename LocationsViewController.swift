//
//  LocationsViewController.swift
//  TrackLocation
//
//  Created by iUS on 11/9/16.
//  Copyright © 2016 ayush. All rights reserved.//
//

import UIKit
import CoreLocation
import CoreData

class LocationsViewController: UITableViewController{

    var managedObjectContext : NSManagedObjectContext!
    //var locations = [Location]()
    
    
    lazy var fetchedResultsController : NSFetchedResultsController<Location> = {
        
        
        let fetchRequest = NSFetchRequest<Location>()
        
        //  - Here you tell the fetch request you’re looking for Location entities
        let entity = Location.entity()
        fetchRequest.entity = entity
        
        //  - The NSSortDescriptor tells the fetch request to sort on the date attribute,in ascending order. In order words, the Location objects that the user added first will be at the top of the list. You can sort on any attribute here (later in this tutorial you’ll sort on the Location’s category as well).
        let sortDescripter1 = NSSortDescriptor(key: "category", ascending: true)
        let sortDescripter2 = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescripter1,sortDescripter2]
        
        
        //The fetch batch size setting allows you to tweak how many objects will be fetched at a time.
        fetchRequest.fetchBatchSize = 20
        
        
        //The cacheName needs to be a unique name that NSFetchedResultsController uses to cache the search results. It keeps this cache around even after your app quits, so the next time the fetch request is lightning fast, as the NSFetchedResultsController doesn’t have to make a round-trip to the database but can simply read from the cache.
        
        //sectionNameKeyPath parameter changed to "category", which means the fetched results controller will group the search results based on the value of the category attribute.
        let fetchedResultsController = NSFetchedResultsController(
                                                    fetchRequest: fetchRequest,
                                                    managedObjectContext: self.managedObjectContext,
                                                    sectionNameKeyPath: "category",
                                                    cacheName: "Locations")
    
        //Through this delegate the view controller is informed that objects have been changed, added or deleted.
        fetchedResultsController.delegate = self
    
        return fetchedResultsController
    }()
    
    
// MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //Every view controller has a built-in Edit button that can be accessed through the editButtonItem property. Tapping that button puts the table in editing mode:
        navigationItem.rightBarButtonItem = editButtonItem
        performFetch()
        
    }
    
    
    //The deinit method is invoked when this view controller is destroyed. It may not strictly be necessary to nil out the delegate here, but it’s a bit of defensive programming that won’t hurt. (Note that in this app the LocationsViewController will never actually be deallocated because it’s one of the top-level view controllers in the tab bar. Still, it’s good to get into the habit of writing deinit methods.)

    deinit {
        
        //It’s always a good idea to explicitly set the delegate to nil when you no longer need the NSFetchedResultsController, just so you don’t get any more notifications that were still pending.
        fetchedResultsController.delegate = nil
    }

    
    // MARK: - Table view data source
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    //configuring title of sections
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //You ask the fetcher object for a list of the sections, which is an array of NSFetchedResultsSectionInfo objects, and then look inside that array to find out how many sections there are and what their names are.
        
        //configuring sections titles
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //The fetched results controller’s sections property returns an array of NSFetchedResultsSectionInfo objects that describe each section of the table view. The number of rows is found in the section info’s numberOfObjects property.
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Location Cell", for: indexPath) as! LocationCell
        
        //Instead of looking into the locations array like you did before, you now ask the fetchedResultsController for the object at the requested index-path. Because it is designed to work closely together with table views, NSFetchedResultsController knows how to deal with index-paths, so that’s very convenient.
        let location = fetchedResultsController.object(at: indexPath)
        cell.configure(for: location)
        
        return cell
    }
    
    //  As soon as you implement this method in your view controller, it enables swipe-to-delete.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            //Get the Location object from the selected row and then tells the context to delete that object. This will trigger the NSFetchedResultsController to send a notification to the delegate (NSFetchedResultsChangeDelete), which then removes the corresponding row from the table.
            let location = fetchedResultsController.object(at: indexPath)
            managedObjectContext.delete(location)
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditLocation"{
        
            let navigationController = segue.destination as! UINavigationController
            
            let locationDetailVC = navigationController.topViewController as! LocationDetailViewController
            
            locationDetailVC.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                
                let location = fetchedResultsController.object(at: indexPath)
                locationDetailVC.locationToEdit = location
                
            }
            
        
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Convenience Methods
    
    
    func performFetch(){
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
        
    }
    /*
     //Fetching before use of NSFetchedResultsViewController
     //  you have the fetch request,you can tell the context to execute it.The fetch() method returns an array with the sorted objects, or throws an error in case something went wrong. That’s why this happens inside a do-try-catch block.
     do {
     locations = try managedObjectContext.fetch(fetchRequest)
     } catch {
     fatalCoreDataError(error)
     }
     */

    

}

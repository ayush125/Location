//
//  AppDelegate.swift
//  TrackLocation
//
//  Created by iUS on 11/9/16.
//  Copyright © 2016 ayush. All rights reserved.//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        
    
        //In order to get a reference to the CurrentLocationViewController you first have to find the UITabBarController and then look at its viewControllers array.
        let tabBarController = window!.rootViewController as! UITabBarController
        
        if let tabBarViewControllers = tabBarController.viewControllers{
        
            let currentLocationVC = tabBarViewControllers[0] as! CurrentLocationViewController
            
            let navigationController = tabBarViewControllers[1] as! UINavigationController
            let locationsVC = navigationController.viewControllers[0]
                as! LocationsViewController
            let mapViewController = tabBarViewControllers[2] as! MapViewController
            currentLocationVC.managedObjectContext=managedObjectContext
            locationsVC.managedObjectContext=managedObjectContext
             mapViewController.managedObjectContext = managedObjectContext
            
        }
        
        
        
        listenForFatalCoreDataNotifications()
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    //Loading data model
    //This is the code you need to load the data model that you’ve defined earlier, and to connect it to an SQLite data store.
    //You instantiate a new NSPersistentContainer object with the name of the data model you created earlier, "DataModel". Then you tell it to loadPersistentStores(), which loads the data from the database into memory and sets up the Core Data stack.
     lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: {
            storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }()
    
    
    //The goal here is to create a so-called NSManagedObjectContext object. That is the object you’ll use to talk to Core Data.
    //To get the NSManagedObjectContext that we’re after, you can simply ask the persistentContainer for its viewContext property.
     lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext

    
    func listenForFatalCoreDataNotifications() {
        // 1 - Tell Notification Center that you want to be notified when ever a My ManagedObjectContextSaveDidFailNotification is posted. The actual code that is performed when that happens sits in a closure following "using:".
        NotificationCenter.default.addObserver(
            forName: MyManagedObjectContextSaveDidFailNotification,
            object: nil, queue: OperationQueue.main, using: { notification in
                // 2
                let alert = UIAlertController(
                    title: "Internal Error",
                    message:
                    "There was a fatal error in the app and it cannot continue.\n\n"
                        + "Press OK to terminate the app. Sorry for the inconvenience.",
                    preferredStyle: .alert)
                
                
                let action = UIAlertAction(title: "OK", style: .default) { _ in
                    let exception = NSException(
                        name: NSExceptionName.internalInconsistencyException,
                        reason: "Fatal Core Data error", userInfo: nil)
                    exception.raise()
                }
                alert.addAction(action)
            
                self.viewControllerForShowingAlert().present(alert, animated: true,completion: nil)

        })
    }
            func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController =
            rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
    
}


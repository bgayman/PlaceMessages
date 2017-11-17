//
//  AppDelegate.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    // MARK: - Types
    struct Constants {
        static let googleAPIKey = <# Google API Key #> // available at https://developers.google.com/maps/documentation/ios-sdk/
    }
    
    // MARK: - Properties
    var window: UIWindow?
    
    // MARK: - App Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey(Constants.googleAPIKey)
        GMSPlacesClient.provideAPIKey(Constants.googleAPIKey)
        
        let splitViewController = window!.rootViewController as! UISplitViewController
        splitViewController.delegate = self
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        return true
    }

    // MARK: - Linking
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let deeplink = Deeplink(url: url),
              let deeplinkMessage = deeplink.deeplinkMessage else { return false }
        DataStore.shared.add(deeplinkMessage)
        Router.show(deeplink: deeplink)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL,
           let deeplink = Deeplink(url: url) {
            Router.show(deeplink: deeplink)
        }
        restorationHandler(nil)
        return true
    }
    
    // MARK: - Split View
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        return true
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        let mapViewController = PlacesMapViewController.makeFromStoryboard()
        return UINavigationController(rootViewController: mapViewController)
    }
}


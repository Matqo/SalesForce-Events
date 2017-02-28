//
//  BeaconController.swift
//  Events
//
//  Created by Martin Futas on 26/02/2017.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit

// 1. Add the ESTBeaconManagerDelegate protocol
class BeaconController: UIViewController, ESTBeaconManagerDelegate  {
    var window: UIWindow?

    let beaconNotificationsManager = BeaconNotificationsManager()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //  put your App ID and App Token here
        // You can get them by adding your app on https://cloud.estimote.com/#/apps
        //ESTConfig.setupAppID("<#App ID#>", andAppToken: "<#App Token#>")
        

        // NOTE: "exit" event has a built-in delay of 30 seconds, to make sure that the user has really exited the beacon's range. The delay is imposed by iOS and is non-adjustable.
        
        return true
    }
    
}

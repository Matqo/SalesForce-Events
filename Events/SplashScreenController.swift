//
//  SplashScreenController.swift
//  Events
//
//  Created by Martin Futas on 13/03/2017.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit
import Foundation
import SalesforceSDKCore

class SplashScreenController: UIViewController, SFRestDelegate
{
    let auth = SFAuthenticationManager.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(auth.haveValidSession){
            //showTabBarController()
			if(!UIApplication.shared.isRegisteredForRemoteNotifications){
				SFPushNotificationManager.sharedInstance().registerForRemoteNotifications()
			}
				showTabBarController()
//			if(UIApplication.shared.isRegisteredForRemoteNotifications){
//				showTabBarController()
//			}
			
        }

        
    }
	

    
    func showTabBarController(){
        if(UIApplication.shared.isRegisteredForRemoteNotifications){
        DispatchQueue.main.async  {
            self.performSegue(withIdentifier: "TabBarSegue", sender: self)
        }
		}else{
			while(!UIApplication.shared.isRegisteredForRemoteNotifications){
			// Do nothing
				#if (arch(i386) || arch(x86_64)) && os(iOS)
					break
				#endif


			}
			DispatchQueue.main.async  {
				self.performSegue(withIdentifier: "TabBarSegue", sender: self)
			}
			
		}
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController") as UIViewController
        //self.navigationController?.pushViewController(vc, animated: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

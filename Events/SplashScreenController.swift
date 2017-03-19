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
            showTabBarController()
        }

        
    }
    
    func showTabBarController(){
        
        DispatchQueue.main.async  {
            self.performSegue(withIdentifier: "TabBarSegue", sender: self)
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

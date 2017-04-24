/*
 Copyright (c) 2015-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import UIKit
import SalesforceSDKCore
import UserNotifications

// Fill these in when creating a new Connected Application on Force.com
//3MVG98_Psg5cppyasQ6Ohn7b5HYhOzYcSHmfIu1r5Tfv54L2qHNf1M1p7oWrOYFeD0FUyZ149zMTQ2O0Sjo7w
//evententhusiasts-developer-edition.eu6.force.com
//eventz-developer-edition.eu11.force.com
let RemoteAccessConsumerKey = "3MVG9HxRZv05HarQY55hpUNJmHewfu1phwhlRH531vUVas5A06.1_mdAHNVkSdDDrTznAhSF0m0PVxYZuo0gB";
let OAuthRedirectURI        = "testsfdc:///mobilesdk/detect/oauth/done";

class AppDelegate : UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate
{
    var window: UIWindow?
    
    let beaconManager = ESTBeaconManager()
    
    override
    init()
    {
        super.init()
        SFLogger.shared().logLevel = .debug
        
        SalesforceSDKManager.shared().connectedAppId = RemoteAccessConsumerKey
        SalesforceSDKManager.shared().connectedAppCallbackUri = OAuthRedirectURI
        SalesforceSDKManager.shared().authScopes = ["web", "api"];
        SalesforceSDKManager.shared().postLaunchAction = {
            [unowned self] (launchActionList: SFSDKLaunchAction) in
            let launchActionString = SalesforceSDKManager.launchActionsStringRepresentation(launchActionList)
            self.log(.info, msg:"Post-launch: launch actions taken: \(launchActionString)");
            self.setupRootViewController();
        }
        SalesforceSDKManager.shared().launchErrorAction = {
            [unowned self] (error: Error, launchActionList: SFSDKLaunchAction) in
            self.log(.error, msg:"Error during SDK launch: \(error.localizedDescription)")
            self.initializeAppViewState()
            SalesforceSDKManager.shared().launch()
        }
        SalesforceSDKManager.shared().postLogoutAction = {
            [unowned self] in
            self.handleSdkManagerLogout()
        }
        SalesforceSDKManager.shared().switchUserAction = {
            [unowned self] (fromUser: SFUserAccount?, toUser: SFUserAccount?) -> () in
            self.handleUserSwitch(fromUser, toUser: toUser)
        }
    }
    
    // MARK: - App delegate lifecycle
        //let beaconNotificationsManager = BeaconNotificationsManager()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        //GMSServices.provideAPIKey("AIzaSyCxfM-A8ZAJ7L1Y_RkOowl-uxnbby2V-4U")
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.initializeAppViewState();
        //self.beaconManager.delegate = self
        //self.beaconManager.requestAlwaysAuthorization()
        
        //
        // If you wish to register for push notifications, uncomment the line below.  Note that,
        // if you want to receive push notifications from Salesforce, you will also need to
        // implement the application:didRegisterForRemoteNotificationsWithDeviceToken: method (below).
        //
		
        //SFPushNotificationManager.sharedInstance().registerForRemoteNotifications()
        
        //
        //Uncomment the code below to see how you can customize the color, textcolor, font and fontsize of the navigation bar
        //
        // let loginViewController = SFLoginViewController.sharedInstance();
        //Set showNavBar to NO if you want to hide the top bar
        // loginViewController.showNavbar = true;
        //Set showSettingsIcon to NO if you want to hide the settings icon on the nav bar
        // loginViewController.showSettingsIcon = true;
        // Set primary color to different color to style the navigation header
        // loginViewController.navBarColor = UIColor(red: 0.051, green: 0.765, blue: 0.733, alpha: 1.0);
        // loginViewController.navBarFont = UIFont (name: "Helvetica Neue", size: 16);
        // loginViewController.navBarTextColor = UIColor.black;
        //
//        self.beaconNotificationsManager.enableNotifications(
//            // TODO: replace with UUID, major and minor of your own beacon
//            for: BeaconID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 37991, minor: 47294),
//            enterMessage: "Welcome to event 1",
//            exitMessage: "Thanks for visiting event 1"
//        )
//        self.beaconNotificationsManager.enableNotifications(
//            // TODO: replace with UUID, major and minor of your own beacon
//            for: BeaconID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 39836, minor: 22244),
//            enterMessage: "Welcome to event 2",
//            exitMessage: "Thanks for visiting event 2"
//        )
//        
        SalesforceSDKManager.shared().launch()
        
        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        //
        // Uncomment the code below to register your device token with the push notification manager
        //
        //
        SFPushNotificationManager.sharedInstance().didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        if (SFUserAccountManager.sharedInstance().currentUser?.credentials.accessToken != nil)
        {
          SFPushNotificationManager.sharedInstance().registerForSalesforceNotifications()
        }
    }

	

//        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> ()) {
//
//					let notification = UILocalNotification()
//					notification.alertBody = "You received a remote notification!"
//					UIApplication.shared.presentLocalNotificationNow(notification)
//    }

	 func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    //let notif = JSON(userInfo) // SwiftyJSON required
							let notification = UILocalNotification()
							notification.alertBody = "You received a remote notification!"
							UIApplication.shared.presentLocalNotificationNow(notification)
		//if notif["callback"]["type"] != nil{
    //NotificationCenter.default.post(name: Notification.Name(rawValue: "myNotif"), object: nil)
    // This is where you read your JSON to know what kind of notification you received, for example :    

}

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error )
    {
        // Respond to any push notification registration errors here.
    }
    
    // MARK: - Private methods
    func initializeAppViewState()
    {
        //        if (!Thread.isMainThread) {
        //            DispatchQueue.main.async {
        //                self.initializeAppViewState()
        //            }
        //            return
        //        }
        
        let board = UIStoryboard(name: "Main", bundle: nil)
        self.window?.rootViewController = board.instantiateViewController(withIdentifier: "entryPoint")
        self.window?.makeKeyAndVisible()
    }
    
    func setupRootViewController()
    {
        //        let rootVC = RootViewController(nibName: nil, bundle: nil)
        //        let navVC = UINavigationController(rootViewController: rootVC)
        //        self.window!.rootViewController = navVC
        let board = UIStoryboard(name: "Main", bundle: nil)
        self.window?.rootViewController = board.instantiateInitialViewController()
    }
    
    func resetViewState(_ postResetBlock: @escaping () -> ())
    {
        if let rootViewController = self.window!.rootViewController {
            if let _ = rootViewController.presentedViewController {
                rootViewController.dismiss(animated: false, completion: postResetBlock)
                return
            }
        }
        
        postResetBlock()
    }
    
    func handleSdkManagerLogout()
    {
        self.log(.debug, msg: "SFAuthenticationManager logged out.  Resetting app.")
        self.resetViewState { () -> () in
            self.initializeAppViewState()
            
            // Multi-user pattern:
            // - If there are two or more existing accounts after logout, let the user choose the account
            //   to switch to.
            // - If there is one existing account, automatically switch to that account.
            // - If there are no further authenticated accounts, present the login screen.
            //
            // Alternatively, you could just go straight to re-initializing your app state, if you know
            // your app does not support multiple accounts.  The logic below will work either way.
            
            var numberOfAccounts : Int;
            let allAccounts = SFUserAccountManager.sharedInstance().allUserAccounts
            numberOfAccounts = allAccounts.count;
            
            if numberOfAccounts > 1 {
                let userSwitchVc = SFDefaultUserManagementViewController(completionBlock: {
                    action in
                    self.window!.rootViewController!.dismiss(animated:true, completion: nil)
                })
                if let actualRootViewController = self.window!.rootViewController {
                    actualRootViewController.present(userSwitchVc!, animated: true, completion: nil)
                }
            } else {
                if (numberOfAccounts == 1) {
                    SFUserAccountManager.sharedInstance().currentUser = allAccounts[0]
                }
                SalesforceSDKManager.shared().launch()
            }
        }
    }
    
    func handleUserSwitch(_ fromUser: SFUserAccount?, toUser: SFUserAccount?)
    {
        let fromUserName = (fromUser != nil) ? fromUser?.userName : "<none>"
        let toUserName = (toUser != nil) ? toUser?.userName : "<none>"
        self.log(.debug, msg:"SFUserAccountManager changed from user \(fromUserName) to \(toUserName).  Resetting app.")
        self.resetViewState { () -> () in
            self.initializeAppViewState()
            SalesforceSDKManager.shared().launch()
        }
    }
}

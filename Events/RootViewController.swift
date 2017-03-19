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


class RootViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, SFRestDelegate
{
    let user = SFUserAccountManager.sharedInstance().currentUser
    let auth = SFAuthenticationManager.shared()
    @IBOutlet weak var CloseEvents: UITableView!
    @IBOutlet weak var fullName: UILabel!


    var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SFLogout(sender:)))
    
    func SFLogout(sender: UIBarButtonItem){
        auth.logout()
        self.log(.debug, msg: "LOGOUT!")
    }
//    @IBOutlet weak var txt: UITextField!
//    @IBOutlet weak var userName: UILabel!
//    @IBAction func Button(_ sender: Any) {
//        self.userName.text = (user?.email)!
//        self.log(.debug, msg: (user?.email)!)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Events"
        navigationItem.rightBarButtonItem = logoutButton
        navigationItem.rightBarButtonItem?.target = self
        fullName.text = user?.accountIdentity.userId
        
        self.CloseEvents.register(UITableViewCell.self, forCellReuseIdentifier:"cell")
        self.CloseEvents.dataSource=self
        self.CloseEvents.delegate=self
        //self.mail.text = user.email

        //self.userName.text = request.
    }
    var dataRows = [NSDictionary]()
    
    override func loadView()
    {
        super.loadView()
        //self.title = "Mobile SDK Sample App"
        
        //Here we use a query that should work on either Force.com or Database.com
        let request = SFRestAPI.sharedInstance().request(forQuery:"SELECT Event_Name__c FROM Event__c ORDER BY Name ASC NULLS FIRST LIMIT 3");
        SFRestAPI.sharedInstance().send(request, delegate: self);
    }
    func request(_ request: SFRestRequest, didLoadResponse jsonResponse: Any)
    {
        self.dataRows = (jsonResponse as! NSDictionary)["records"] as! [NSDictionary]
        self.log(.debug, msg: "request:didLoadResponse: #records: \(self.dataRows.count)")
        DispatchQueue.main.async(execute: {
            self.CloseEvents.reloadData()
        })
    }
    //        func numberOfSectionsInTableView(EventTable: UITableView) -> Int
    //        {
    //            return 1
    //        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataRows.count
    }
    //var items=["Dog","Cat"]
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.CloseEvents.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        let obj = dataRows[indexPath.row]
        cell.textLabel!.text = obj["Event_Name__c"] as? String
        self.log(.debug, msg: "RECORD:: \(obj["Name"] as? String)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = dataRows[indexPath.row]
        let myVC = storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        myVC.stringPassed = (obj["Event_Name__c"] as? String)!
        self.present(myVC, animated: true, completion: nil);
        print("You tapped on cell \(indexPath.row)")
    }

    
    
//    var dataRows = [NSDictionary]()
//    
//    // MARK: - View lifecycle
//    override func loadView()
//    {
//        super.loadView()
//        self.title = "Mobile SDK Sample App"
//        
//        //Here we use a query that should work on either Force.com or Database.com
//        let request = SFRestAPI.sharedInstance().request(forQuery:"SELECT Name FROM User LIMIT 10");
//        SFRestAPI.sharedInstance().send(request, delegate: self);
//    }
//
//    // MARK: - SFRestDelegate
//    func request(_ request: SFRestRequest, didLoadResponse jsonResponse: Any)
//    {
//        self.dataRows = (jsonResponse as! NSDictionary)["records"] as! [NSDictionary]
//        self.log(.debug, msg: "request:didLoadResponse: #records: \(self.dataRows.count)")
//        DispatchQueue.main.async(execute: {
//            self.tableView.reloadData()
//        })
//    }
//    
//    func request(_ request: SFRestRequest, didFailLoadWithError error: Error)
//    {
//        self.log(.debug, msg: "didFailLoadWithError: \(error)")
//        // Add your failed error handling here
//    }
//    
//    func requestDidCancelLoad(_ request: SFRestRequest)
//    {
//        self.log(.debug, msg: "requestDidCancelLoad: \(request)")
//        // Add your failed error handling here
//    }
//    
//    func requestDidTimeout(_ request: SFRestRequest)
//    {
//        self.log(.debug, msg: "requestDidTimeout: \(request)")
//        // Add your failed error handling here
//    }
//    
//    // MARK: - Table view data source
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int
//    {
//        return 1
//    }
//    
//    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int
//    {
//        return self.dataRows.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
//    {
//        let cellIdentifier = "CellIdentifier"
//        
//        // Dequeue or create a cell of the appropriate type.
//        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier:cellIdentifier)
//        if (cell == nil)
//        {
//            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
//        }
//        
//        // If you want to add an image to your cell, here's how.
//        let image = UIImage(named: "icon.png")
//        cell!.imageView!.image = image
//        
//        // Configure the cell to show the data.
//        let obj = dataRows[indexPath.row]
//        cell!.textLabel!.text = obj["Name"] as? String
//        
//        // This adds the arrow to the right hand side.
//        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
//        
//        return cell!
//    }
}

//
//  EventsControllerViewController.swift
//  Events
//
//  Created by Martin Futas on 01/02/2017.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit
import Foundation
import SalesforceSDKCore

class EventsController: UIViewController, UITableViewDataSource, UITableViewDelegate, SFRestDelegate {
    let user = SFUserAccountManager.sharedInstance().currentUser

    @IBOutlet weak var EventTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.EventTable.register(UITableViewCell.self, forCellReuseIdentifier:"cell")
        self.EventTable.dataSource=self
        self.EventTable.delegate=self
        //self.EventTable.register(EventCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var dataRows = [NSDictionary]()

        override func loadView()
        {
            super.loadView()
            //self.title = "Mobile SDK Sample App"
    
            navigationItem.title = "Events"

            
            //Here we use a query that should work on either Force.com or Database.com
            let request = SFRestAPI.sharedInstance().request(forQuery:"SELECT Name,CreatedById,Image__c,Event_Name__c FROM Event__c ORDER BY Name ASC NULLS FIRST");
            SFRestAPI.sharedInstance().send(request, delegate: self);
        }
        func request(_ request: SFRestRequest, didLoadResponse jsonResponse: Any)
        {
            self.dataRows = (jsonResponse as! NSDictionary)["records"] as! [NSDictionary]
            self.log(.debug, msg: "request:didLoadResponse: #records: \(self.dataRows.count)")
            DispatchQueue.main.async(execute: {
                self.EventTable.reloadData()
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
        let cell = self.EventTable.dequeueReusableCell(withIdentifier: "customCell")! as! EventCell
        let obj = dataRows[indexPath.row]
        //cell.textLabel!.text = obj["Name"] as? String
        let imageURL = URL(string: (obj["Image__c"] as? String)!)!
        let imgData = NSData(contentsOf:imageURL)!
        cell.myImage.image = UIImage(data:imgData as Data)
        cell.eventName!.text = obj["Event_Name__c"] as? String
        cell.createdBy!.text = obj["CreatedById"] as? String
        self.log(.debug, msg: "RECORD:: \(obj["Name"] as? String)")

        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = dataRows[indexPath.row]
        let myVC = storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        myVC.stringPassed = (obj["Event_Name__c"] as? String)!
        navigationController?.pushViewController(myVC, animated: true)

        print("You tapped on cell \(indexPath.row)")
//                let obj = dataRows[indexPath.row]
//                let myVC = storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
//                myVC.stringPassed = (obj["Event_Name__c"] as? String)!
//        self.present(myVC, animated: true, completion: nil);
        //navigationController?.pushViewController(myVC, animated: true)
    }
//        override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int
//        {
//            return self.dataRows.count
//        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

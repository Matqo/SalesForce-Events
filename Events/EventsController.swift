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

    let beaconManager = ESTBeaconManager()

    var refreshControl = UIRefreshControl()

    @IBOutlet weak var EventTable: UITableView!
    
    func pullToRefresh(_ sender : Any){
        let request = SFRestAPI.sharedInstance().request(forQuery:"SELECT Name,CreatedById,Image__c,Event_Name__c,Id,Latitude__c,Longitude__c FROM Event__c ORDER BY Name ASC NULLS FIRST");
        SFRestAPI.sharedInstance().send(request, delegate: self);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.EventTable.register(UITableViewCell.self, forCellReuseIdentifier:"cell")
        self.EventTable.dataSource=self
        self.EventTable.delegate=self
        //self.EventTable.register(EventCell.self, forCellReuseIdentifier: "cell")
        self.beaconManager.requestAlwaysAuthorization()
        pullToRefresh(self)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh events")
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: UIControlEvents.valueChanged)
        self.EventTable.addSubview(refreshControl)
        

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
            
        }
        func request(_ request: SFRestRequest, didLoadResponse jsonResponse: Any)
        {
            self.dataRows = (jsonResponse as! NSDictionary)["records"] as! [NSDictionary]
            self.log(.debug, msg: "request:didLoadResponse: #records: \(self.dataRows.count)")
            refreshControl.endRefreshing()
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
        
        cell.createdBy!.text = ""
        
        let latDouble = (((obj["Latitude__c"] as? NSString)!).doubleValue)
        let lonDouble = (((obj["Longitude__c"] as? NSString)!).doubleValue)
        let eventCoordinates:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lonDouble,latDouble)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: eventCoordinates.latitude,longitude: eventCoordinates.longitude), completionHandler: {
            (placemarks, error) -> Void in
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                cell.createdBy!.text?.append((zip as String) as String + ", ")
            }
            if let country = placeMark.addressDictionary!["Country"] as? NSString {
                cell.createdBy!.text?.append((country as String) as String)
            }
        })
        
        
        //self.log(.debug, msg: "RECORD:: \(obj["Name"] as? String)")

        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = dataRows[indexPath.row]
        let myVC = storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        myVC.stringPassed = (obj["Event_Name__c"] as? String)!
        myVC.ID = (obj["Id"] as? String)!
        myVC.longitude=(obj["Longitude__c"] as? String)!
        myVC.latitude=(obj["Latitude__c"] as? String)!
        
        navigationController?.pushViewController(myVC, animated: true)

        print("You tapped on cell \(indexPath.row)")
        //print(obj["Id"] as? String!)
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

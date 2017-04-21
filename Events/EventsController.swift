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

class EventsController: UIViewController, UITableViewDataSource, UITableViewDelegate, ESTBeaconManagerDelegate, SFRestDelegate {
	
	let beaconManager = ESTBeaconManager()
	let deviceManager = ESTDeviceManager()
	
	let beaconRegion = CLBeaconRegion(
		proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
		identifier: "ranged region")
	
	
	func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon],
	                   in region: CLBeaconRegion) {
		//print(UIApplication.shared.backgroundTimeRemaining.description)
		let knownBeacons = beacons.filter{$0.proximity != CLProximity.unknown}
		//proximityEvents.removeAll()
		//		for index in 0..<proximityEvents.count{
		//			proximityEvents[index]["Distance_From"] = Int.max
		//		}
		proximityEvents.removeAll()
		//modifiedDataRows = controlRows
		dataRows = modifiedDataRows
		if (knownBeacons.count > 0) {
			for beacon in knownBeacons{
				//print(beacon.accuracy)
				
				for i in 0..<modifiedDataRows.count{
					let major:NSNumber = NSNumber(value:(modifiedDataRows[i]["Major__c"] as! NSString).integerValue)
					let minor:NSNumber = NSNumber(value:(modifiedDataRows[i]["Minor__c"] as! NSString).integerValue)
					if(beacon.major==major && beacon.minor==minor){
						//print(nDataRows[i]["Event_Name__c"] as? String)
						modifiedDataRows[i]["Distance_From"]=beacon.proximity.rawValue
						proximityEvents.append(modifiedDataRows[i])
						dataRows = dataRows.filter{ $0["Id"] as? String != modifiedDataRows[i]["Id"] as? String}
//
//						if(dataRows.indices.contains(i)){
//							dataRows.remove(at: i)
//							//dataRows.remove
//							
//						}
					}
					
				}
			}
			//let closestBeacon = knownBeacons[0] as CLBeacon
			
			
		}
		
	}
	
var reloadTimer: Timer!
func runTimedCode() {
	DispatchQueue.main.async(execute: {
		self.EventTable.reloadData()
	})
}



	
	func getAddresses(_ sender: Any){
		
		func geoCode(addresses: [Dictionary<String, Any>], results: [Dictionary<String, Any>], completion: @escaping ([Dictionary<String, Any>]) -> Void ) {
			guard let eventID = (((addresses.first?["Id"] as? NSString))) else {
				completion(results)
				return
			}
			
			let latDouble = (((addresses.first?["Latitude__c"] as? NSString)!).doubleValue)
			let lonDouble = (((addresses.first?["Longitude__c"] as? NSString)!).doubleValue)
			
			var address = ""
			let eventCoordinates:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lonDouble,latDouble)
			let geoCoder = CLGeocoder()
			geoCoder.reverseGeocodeLocation(CLLocation(latitude: eventCoordinates.latitude,longitude: eventCoordinates.longitude), completionHandler: {
				(placemarks, error) -> Void in
				var updatedResults = results
				var placeMark: CLPlacemark!
				placeMark = placemarks?[0]
				if let zip = placeMark.addressDictionary!["City"] as? NSString {
					address = ((zip as String) as String + ",\n")
				}
				if let country = placeMark.addressDictionary!["Country"] as? NSString {
					address.append((country as String) as String)
					updatedResults.append(["Id":eventID,"cAddress":address])
				}
				let remainingRows = [Dictionary<String, Any>](addresses[1..<addresses.count])
				geoCode(addresses: remainingRows, results: updatedResults, completion: completion)
				
			})
		}
		
		geoCode(addresses: dataRows, results: oResults) {results in
			self.oResults = results}
	}

    
    let user = SFUserAccountManager.sharedInstance().currentUser

    var refreshControl = UIRefreshControl()

    @IBOutlet weak var EventTable: UITableView!
    
    func pullToRefresh(_ sender : Any){
			self.beaconManager.stopRangingBeacons(in: self.beaconRegion)

        let request = SFRestAPI.sharedInstance().request(forQuery:"SELECT Name,CreatedById,Image__c,Event_Name__c,Id,Latitude__c,Longitude__c,Date__c,Description__c,Major__c,Minor__c FROM Event__c ORDER BY Name ASC NULLS FIRST");
        SFRestAPI.sharedInstance().send(request, delegate: self);
		self.beaconManager.startRangingBeacons(in: self.beaconRegion)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.beaconManager.requestAlwaysAuthorization()
		self.beaconManager.delegate = self
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
		reloadTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)


   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var dataRows = [Dictionary<String, Any>]()
	var proximityEvents = [Dictionary<String, Any>]()
	var modifiedDataRows = [Dictionary<String, Any>]()
	var oResults = [Dictionary<String, Any>]()
	var controlRows = [Dictionary<String, Any>]()
        override func loadView()
        {
            super.loadView()
            //self.title = "Mobile SDK Sample App"
    
            navigationItem.title = "Events"

            
            //Here we use a query that should work on either Force.com or Database.com
            
        }
        func request(_ request: SFRestRequest, didLoadResponse jsonResponse: Any)
        {
            self.dataRows = (jsonResponse as! NSDictionary)["records"] as! [NSDictionary] as! [Dictionary<String, Any>]
            self.log(.debug, msg: "request:didLoadResponse: #records: \(self.dataRows.count)")
            refreshControl.endRefreshing()
			modifiedDataRows = dataRows
			proximityEvents.removeAll()
			getAddresses(self)
			controlRows = dataRows
            DispatchQueue.main.async(execute: {
                self.EventTable.reloadData()
            })
        }
//        func numberOfSectionsInTableView(EventTable: UITableView) -> Int
//        {
//            return 1
//        }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            return self.dataRows.count
//    }
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(section == 0 && proximityEvents.count != 0){
			proximityEvents.sort {
				item1, item2 in
				let distance1 = item1["Distance_From"] as! Int
				let distance2 = item2["Distance_From"] as! Int
				return distance1 < distance2
				
			}
			return proximityEvents.count
		}else if(section == 1 && dataRows.count != 0){
			return dataRows.count
		}else{
			return 0}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if(section == 0 && proximityEvents.count != 0){
			return "Nearby Events"
		}else if(section == 1 && dataRows.count != 0){
			return "Available Events"
		}else{
		return ""
		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if(proximityEvents.count == 0 && section == 0){
			return 0.0001
		}else{
			return 30
		}
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.0001
	}
	
    //var items=["Dog","Cat"]
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if(indexPath.section == 0){
			let cell = self.EventTable.dequeueReusableCell(withIdentifier: "customCell")! as! EventCell
			let obj = proximityEvents[indexPath.row]
			//cell.textLabel!.text = obj["Name"] as? String
			let imageURL = URL(string: (obj["Image__c"] as? String)!)!
			let imgData = NSData(contentsOf:imageURL)!
			cell.myImage.image = UIImage(data:imgData as Data)
			cell.eventName!.text = obj["Event_Name__c"] as? String
			if let distance = ((obj["Distance_From"] as? Int)){
				cell.Distance!.text? = (" < \(distance)m")
			}
			let eventDate = obj["Date__c"] as? String
			//let date = eventDate?.substring(to: 9)
			let startIndexDate = (eventDate?.index((eventDate?.startIndex)!, offsetBy: 0))!
			let endIndexDate = (eventDate?.index((eventDate?.startIndex)!, offsetBy: 9))!
			let startIndexTime = (eventDate?.index((eventDate?.startIndex)!, offsetBy: 11))!
			let endIndexTime = (eventDate?.index((eventDate?.startIndex)!, offsetBy: 15))!
			let date = eventDate?[startIndexDate...endIndexDate]
			let time = eventDate?[startIndexTime...endIndexTime]
			cell.dateTime.text? = date! + ", at " + time!
			cell.createdBy.numberOfLines = 0
			cell.createdBy!.text = ""
			
			for i in 0..<oResults.count{
				let resultId = oResults[i]["Id"] as? String
				if(resultId == obj["Id"] as? String){
					cell.createdBy.text = oResults[i]["cAddress"] as? String
				}
			
			}
			//self.log(.debug, msg: "RECORD:: \(obj["Name"] as? String)")
			
			return cell

		}
		else{
        let cell = self.EventTable.dequeueReusableCell(withIdentifier: "customCell")! as! EventCell
        let obj = dataRows[indexPath.row]
        //cell.textLabel!.text = obj["Name"] as? String
        let imageURL = URL(string: (obj["Image__c"] as? String)!)!
        let imgData = NSData(contentsOf:imageURL)!
        cell.myImage.image = UIImage(data:imgData as Data)
        cell.eventName!.text = obj["Event_Name__c"] as? String
		
		let eventDate = obj["Date__c"] as? String
		//let date = eventDate?.substring(to: 9)
		let startIndexDate = (eventDate?.index((eventDate?.startIndex)!, offsetBy: 0))!
		let endIndexDate = (eventDate?.index((eventDate?.startIndex)!, offsetBy: 9))!
		let startIndexTime = (eventDate?.index((eventDate?.startIndex)!, offsetBy: 11))!
		let endIndexTime = (eventDate?.index((eventDate?.startIndex)!, offsetBy: 15))!
		let date = eventDate?[startIndexDate...endIndexDate]
		let time = eventDate?[startIndexTime...endIndexTime]
		cell.dateTime.text? = date! + ", at " + time!
		cell.createdBy.numberOfLines = 0
		cell.createdBy!.text = ""
			
			for i in 0..<oResults.count{
				let resultId = oResults[i]["Id"] as? String
				if(resultId == obj["Id"] as? String){
					cell.createdBy.text = oResults[i]["cAddress"] as? String
				}
			}
        //self.log(.debug, msg: "RECORD:: \(obj["Name"] as? String)")

        return cell
    }
	}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if(indexPath.section == 0){
			let obj = proximityEvents[indexPath.row]
			let myVC = storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
			myVC.stringPassed = (obj["Event_Name__c"] as? String)!
			myVC.ID = (obj["Id"] as? String)!
			myVC.longitude=(obj["Longitude__c"] as? String)!
			myVC.latitude=(obj["Latitude__c"] as? String)!
			myVC.imageURL=(obj["Image__c"] as? String)!
			myVC.date=(obj["Date__c"] as? String)!
			if let eventDescription = (obj["Description__c"] as? String) {
				myVC.desc = eventDescription
			}else{
				myVC.desc = "Description for event " + myVC.stringPassed + " has not been submitted."
			}
			navigationController?.pushViewController(myVC, animated: true)
			tableView.deselectRow(at: indexPath, animated: true)
			
			print("You tapped on cell \(indexPath.row)")
		
		}else{
        let obj = dataRows[indexPath.row]
        let myVC = storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        myVC.stringPassed = (obj["Event_Name__c"] as? String)!
        myVC.ID = (obj["Id"] as? String)!
        myVC.longitude=(obj["Longitude__c"] as? String)!
        myVC.latitude=(obj["Latitude__c"] as? String)!
		myVC.imageURL=(obj["Image__c"] as? String)!
		myVC.date=(obj["Date__c"] as? String)!
		if let eventDescription = (obj["Description__c"] as? String) {
			myVC.desc = eventDescription
		}else{
			myVC.desc = "Description for event " + myVC.stringPassed + " has not been submitted."
		}
        navigationController?.pushViewController(myVC, animated: true)
		tableView.deselectRow(at: indexPath, animated: true)

        print("You tapped on cell \(indexPath.row)")
		
		}

		
        //print(obj["Id"] as? String!)
//                let obj = dataRows[indexPath.row]
//                let myVC = storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
//                myVC.stringPassed = (obj["Event_Name__c"] as? String)!
//        self.present(myVC, animated: true, completion: nil);
        //navigationController?.pushViewController(myVC, animated: true)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.beaconManager.startRangingBeacons(in: self.beaconRegion)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.beaconManager.stopRangingBeacons(in: self.beaconRegion)
//		proximityEvents.removeAll()
//		DispatchQueue.main.async(execute: {
//			self.EventTable.reloadData()
//		})
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

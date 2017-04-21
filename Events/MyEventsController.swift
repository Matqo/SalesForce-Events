//
//  MyEventsController.swift
//  Events
//
//  Created by Martin Futas on 04/03/2017.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit
import Foundation
import SalesforceSDKCore

class MyEventsController: UIViewController, UITableViewDataSource, UITableViewDelegate, ESTBeaconManagerDelegate, SFRestDelegate {
	let user = SFUserAccountManager.sharedInstance().currentUser
	
	@IBOutlet weak var EventTable: UITableView!
	
	let beaconManager = ESTBeaconManager()
	let deviceManager = ESTDeviceManager()
	let locationManager = CLLocationManager()
	
	let beaconRegion = CLBeaconRegion(
		proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
		identifier: "local region")
	
	
	func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon],
	                   in region: CLBeaconRegion) {
		//print(UIApplication.shared.backgroundTimeRemaining.description)
		let knownBeacons = beacons.filter{$0.proximity != CLProximity.unknown}
		//proximityEvents.removeAll()
		//		for index in 0..<proximityEvents.count{
		//			proximityEvents[index]["Distance_From"] = Int.max
		//		}
		proximityEvents.removeAll()
		nDataRows = modifiedNDataRows
		if (knownBeacons.count > 0) {
			for beacon in knownBeacons{
				//print(beacon.accuracy)
				
				for i in 0..<modifiedNDataRows.count{
					let major:NSNumber = NSNumber(value:(modifiedNDataRows[i]["Major__c"] as! NSString).integerValue)
					let minor:NSNumber = NSNumber(value:(modifiedNDataRows[i]["Minor__c"] as! NSString).integerValue)
					if(beacon.major==major && beacon.minor==minor){
						//print(nDataRows[i]["Event_Name__c"] as? String)
						modifiedNDataRows[i]["Distance_From"]=beacon.proximity.rawValue
						proximityEvents.append(modifiedNDataRows[i])
						
						if(beacon.proximity.rawValue < 2 ){
							let notification = UILocalNotification()
							var attendanceID = ""
							if(getID.count != 0){
								for position in getID{
									if let testID = position["Event_ID__c"] as? String{
										if(testID == (modifiedNDataRows[i]["Id"] as? String)!){
											attendanceID = (position["Id"] as? String)!
										}
									}
								}
								print("ATTENDANCE ID:: \(attendanceID)")
								
								//var uID = (user?.accountIdentity.userId)!
								//var eID = (nDataRows[i]["Event_ID__C"] as? String)!
								//self.log(.debug, msg: "You arrived at  \(nDataRows[i]["Event_Name__c"])")
								SFRestAPI.sharedInstance().performUpdate(
									withObjectType: "Events_Users__c",
									objectId: attendanceID,
									fields: ["Attended__c":true],
									fail: { (error: Error?) in
										self.log(.debug, msg: "Fail" + (error?.localizedDescription)!)
										
										
								}) { (complete: [AnyHashable : Any]?) in
									self.log(.debug, msg: "Success" )
									notification.alertBody = "You have arrived at \(self.modifiedNDataRows[i]["Event_Name__c"])!"
									UIApplication.shared.presentLocalNotificationNow(notification)
									self.proximityEvents.removeAll()
									self.refresh(self)
								;}
							}
						}
						
						//						var found = false
						//						for j in 0..<proximityEvents.count{
						//							if(dataRows[i]["Name"] as? String == proximityEvents[j]["Name"] as? String){
						//								proximityEvents[j] = dataRows[i]
						//								found = true
						//							}
						//						}
						//						if(found == false){
						
						//proximityEvents.append(modifiedNDataRows[i])
						nDataRows = nDataRows.filter{ $0["Id"] as? String != modifiedNDataRows[i]["Id"] as? String}
						//}
						//proximityEvents.insert(dataRows[i], at: i)
						DispatchQueue.main.async(execute: {
							self.EventTable.reloadData()
						})
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
		
		geoCode(addresses: nDataRows, results: nResults) {results in
			self.nResults = results}
		
		geoCode(addresses: dataRows, results: oResults) {results in
			self.oResults = results}
	}
	
	
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		//self.beaconManager.stopRangingBeacons(in: self.beaconRegion)
		proximityEvents.removeAll()
		backgroundUpdate = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
		nDataRows.removeAll()
		modifiedNDataRows.removeAll()
		
	}
	
	//	func applicationDidEnterBackground(_ application: UIApplication){
	//	print("ABCDABCDABCDABCDABCDABCDACD")
	//		backgroundUpdate = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
	//
	//	}
	
	func beaconManager(manager: AnyObject!, didEnterRegion region: CLBeaconRegion!) {
		print("didEnter")
		locationManager.startUpdatingLocation()
		beaconManager.startRangingBeacons(in: beaconRegion)
	}
	
	func beaconManager(manager: AnyObject!, didExitRegion region: CLBeaconRegion!) {
		print("didExit")
		locationManager.stopUpdatingLocation()
		beaconManager.stopRangingBeacons(in: beaconRegion)
	}
	
	func beaconManager(manager: AnyObject!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
		print("didRangeBeacons: \(beacons)")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "My Events"
		// Do any additional setup after loading the view.
		self.EventTable.register(UITableViewCell.self, forCellReuseIdentifier:"cell")
		self.EventTable.dataSource=self
		self.EventTable.delegate=self
		//self.EventTable.register(EventCell.self, forCellReuseIdentifier: "cell")
		reloadTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)

	}
	
	func beaconController(_ sender: Any){
		locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
		locationManager.allowsBackgroundLocationUpdates = true
		locationManager.startMonitoringSignificantLocationChanges()
		self.beaconManager.requestAlwaysAuthorization()
		self.beaconManager.delegate = self
		//self.beaconManager.stopRangingBeaconsInAllRegions()
		//self.beaconManager.startRangingBeacons(in: self.beaconRegion)
		self.beaconManager.startMonitoring(for: beaconRegion)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	var dataRows = [Dictionary<String, Any>]()
	var nDataRows = [Dictionary<String, Any>]()
	var modifiedNDataRows = [Dictionary<String, Any>]()
	var proximityEvents = [Dictionary<String, Any>]()
	var getID  = [Dictionary<String, Any>]()
	var nResults  = [Dictionary<String, Any>]()
	var oResults  = [Dictionary<String, Any>]()
	var queryOne = 0
	var queryTwo = 0
	var tempQuery = 0
	var tableSections = 0
	var ctrlOne = false
	var ctrlTwo = false
	
	func refresh(_ sender : Any){
		let attendedQuery = "SELECT Id,Name,CreatedById,Image__c,Event_Name__c,Date__c,Longitude__c,Latitude__c,Description__c FROM Event__C WHERE Id IN (SELECT Event_ID__c FROM Events_Users__c WHERE User_ID__c = \'"+(user?.accountIdentity.userId)!+"\' AND Attended__c = true)"
		let noAttendedQuery = "SELECT Id,Name,CreatedById,Image__c,Event_Name__c,Major__c,Minor__c,Date__c,Longitude__c,Latitude__c,Description__c FROM Event__C WHERE Id IN (SELECT Event_ID__c FROM Events_Users__c WHERE User_ID__c = \'"+(user?.accountIdentity.userId)!+"\' AND Attended__c = false)"
		//self.log(.debug, msg: "Query is: \(query)")
		let attendedRequest = SFRestAPI.sharedInstance().request(forQuery:attendedQuery);
		let toAttendRequest = SFRestAPI.sharedInstance().request(forQuery:noAttendedQuery);
		
		queryOne = attendedRequest.hashValue
		queryTwo = toAttendRequest.hashValue
		
		ctrlOne = false
		ctrlTwo = false
		
		SFRestAPI.sharedInstance().send(attendedRequest, delegate: self);
		SFRestAPI.sharedInstance().send(toAttendRequest, delegate: self);
		
		let getIdQuery = "SELECT Id,Event_ID__c FROM Events_Users__c"
		let getIDq = SFRestAPI.sharedInstance().request(forQuery:getIdQuery);
		
		
		tempQuery = getIDq.hashValue
		SFRestAPI.sharedInstance().send(getIDq, delegate: self);
		
	}
	
	override func loadView()
	{
		super.loadView()
		refresh(self)
	}
	
	func request(_ request: SFRestRequest, didLoadResponse jsonResponse: Any)
	{
		if(request.hashValue == queryOne){
			self.dataRows = ((jsonResponse as! NSDictionary)["records"] as! [NSDictionary]) as! [Dictionary<String,Any>]
			self.log(.debug, msg: "RECORDS FOR HAS ATTENDED: \(self.dataRows.count)")
			ctrlOne = true
		}else if(request.hashValue == queryTwo){
			self.nDataRows = ((jsonResponse as! NSDictionary)["records"] as! [NSDictionary]) as! [Dictionary<String,Any>]
			self.log(.debug, msg: "RECORDS FOR HAS !NOT! ATTENDED: \(self.nDataRows.count)")
			modifiedNDataRows = nDataRows
			ctrlTwo = true
		}else if(request.hashValue == tempQuery){
			
			self.getID = ((jsonResponse as! NSDictionary)["records"] as! [NSDictionary]) as! [Dictionary<String,Any>]
			
			self.log(.debug, msg: "IDENTIFICATION RECORDS: \(self.getID.count)")
			
		}
		
		if(ctrlOne && ctrlTwo){
			DispatchQueue.main.async(execute: {
				self.getAddresses(self)
				self.EventTable.reloadData()
				self.beaconController(self)
			})
		}
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		//		tableSections = 0
		//		var sections = 0
		//		if(nDataRows.count != 0){sections += 1}
		//		if(dataRows.count != 0){sections += 1}
		//		if(proximityEvents.count != 0){sections += 1}
		//		tableSections = sections
		//		return sections
		//		if(nDataRows.count == 0 && dataRows.count != 0){
		//			return 1
		//		}else if(nDataRows.count != 0 && dataRows.count == 0){
		//			return 1
		//		}else{
		//			return 2
		//		}
		return 3
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//if(tableSections == 3){
		if(section == 0 && proximityEvents.count != 0){
			return proximityEvents.count
		}else if(section == 1 && nDataRows.count != 0){
			return nDataRows.count
		}else if(section == 2 && dataRows.count != 0){
			return dataRows.count
		}else{
			return 0}
		//		}else{
		//		if (section == 0){
		//			if(nDataRows.count == 0){
		//				return dataRows.count
		//			}else{
		//				return nDataRows.count
		//			}
		//		}
		//		else if(section == 1){
		//			return dataRows.count
		//		}
		//		else{return 0}
		//		}
		
		
		
		
		
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if(section == 0){
			if(proximityEvents.count != 0){
				return "Nearby Upcoming Events"
			}else{
				return ""}
		}else if(section == 1){
			if(nDataRows.count != 0){
				return "Upcoming Events"
			}else{
				return ""}
		}else{
			if(dataRows.count != 0){
				return "Attended Events"
			}else{
				return ""}
		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if(proximityEvents.count == 0 && section == 0){
			return 0.0001
		}else if(nDataRows.count == 0 && section == 1){
			return 0.0001
		}else if(dataRows.count == 0 && section == 2){
			return 0.0001
		}
		else{
			return 30
		}
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.0001
	}
	
	
	
	//var items=["Dog","Cat"]
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if(indexPath.section == 0){
			let cell = self.EventTable.dequeueReusableCell(withIdentifier: "customCells")! as! myEventCell
			print(indexPath.row)
			var obj = proximityEvents[indexPath.row]
			//cell.textLabel!.text = obj["Name"] as? String
			let imageURL = URL(string: (obj["Image__c"] as? String)!)!
			let imgData = NSData(contentsOf:imageURL)!
			let distance = ((obj["Distance_From"] as? Int)!)
			cell.Distance!.text?.append(" < \(distance)m")
			cell.myImage.image = UIImage(data:imgData as Data)
			cell.eventName!.text = obj["Event_Name__c"] as? String
			self.log(.debug, msg: "RECORD:: \(obj["Name"] as? String)")
			
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
			if(cell.createdBy.text != ""){
			obj["cAddress"] = cell.createdBy.text
			}
			//if let testID = position["Event_ID__c"] as? String{
			for i in 0..<nResults.count{
				let resultId = nResults[i]["Id"] as? String
				if(resultId == obj["Id"] as? String){
					cell.createdBy.text = nResults[i]["cAddress"] as? String
				}
			}
			return cell
			
		}
		else if(indexPath.section == 1){
			print(nDataRows.count)
			let cell = self.EventTable.dequeueReusableCell(withIdentifier: "customCells")! as! myEventCell
			print(indexPath.row)
			var obj = nDataRows[indexPath.row]
			//cell.textLabel!.text = obj["Name"] as? String
			let imageURL = URL(string: (obj["Image__c"] as? String)!)!
			let imgData = NSData(contentsOf:imageURL)!
			cell.myImage.image = UIImage(data:imgData as Data)
			cell.eventName!.text = obj["Event_Name__c"] as? String
			self.log(.debug, msg: "RECORD:: \(obj["Name"] as? String)")
			
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
			print(nResults.count)
			for i in 0..<nResults.count{
				let resultId = nResults[i]["Id"] as? String
				if(resultId == obj["Id"] as? String){
					cell.createdBy.text = nResults[i]["cAddress"] as? String
				}
			}

			return cell
			
		}else{
			let cell = self.EventTable.dequeueReusableCell(withIdentifier: "customCells")! as! myEventCell
			var obj = dataRows[indexPath.row]
			//cell.textLabel!.text = obj["Name"] as? String
			let imageURL = URL(string: (obj["Image__c"] as? String)!)!
			let imgData = NSData(contentsOf:imageURL)!
			cell.myImage.image = UIImage(data:imgData as Data)
			cell.eventName!.text = obj["Event_Name__c"] as? String
			self.log(.debug, msg: "RECORD:: \(obj["Name"] as? String)")
			
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
			if(cell.createdBy.text != ""){
				obj["cAddress"] = cell.createdBy.text
			}
			for i in 0..<oResults.count{
				let resultId = oResults[i]["Id"] as? String
				if(resultId == obj["Id"] as? String){
					cell.createdBy.text = oResults[i]["cAddress"] as? String
				}
			}

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
			
		}else if(indexPath.section == 1){
			let obj = nDataRows[indexPath.row]
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
		else{
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
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.beaconManager.startRangingBeacons(in: self.beaconRegion)
		refresh(self)
		
		
	}
	
	var backgroundUpdate: UIBackgroundTaskIdentifier!
	
	
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

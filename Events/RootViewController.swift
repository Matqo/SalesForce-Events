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

class RootViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource,
 ESTBeaconManagerDelegate, SFRestDelegate
{
	
	let beaconManager = ESTBeaconManager()
	let deviceManager = ESTDeviceManager()

	let beaconRegion = CLBeaconRegion(
		proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
		identifier: "ranged region")
	

	func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon],
                   in region: CLBeaconRegion) {
	let knownBeacons = beacons.filter{$0.proximity != CLProximity.unknown}
	//proximityEvents.removeAll()
		for index in 0..<proximityEvents.count{
			proximityEvents[index]["Distance_From"] = Int.max
		}
	if	(knownBeacons.count == 0){
//		proximityEvents.removeAll()
//
//		DispatchQueue.main.async(execute: {
//			self.CloseEvents.reloadData()
//		})
	}
		
	else if (knownBeacons.count > 0) {
		for beacon in knownBeacons{
			//print(beacon.accuracy)

			for i in 0..<dataRows.count{
				let major:NSNumber = NSNumber(value:(dataRows[i]["Major__c"] as! NSString).integerValue)
				let minor:NSNumber = NSNumber(value:(dataRows[i]["Minor__c"] as! NSString).integerValue)
				if(beacon.major==major && beacon.minor==minor){
					print(dataRows[i]["Event_Name__c"] as? String)
					//print(beacon.proximity.rawValue)
					dataRows[i]["Distance_From"]=beacon.proximity.rawValue
//					let temperatureNotification = ESTTelemetryNotificationTemperature { (temperature) in
//						print("Current temperature: \(temperature.temperatureInCelsius) C")
//						self.dataRows[i]["Temperature"]=temperature.temperatureInCelsius
//						print(beacon.beaconID.asString)
//						
//					}
//					
//					deviceManager.register(forTelemetryNotification: temperatureNotification)
//					let myTemp = ESTTelemetryInfoTemperature.init(shortIdentifier: "")

					
					var found = false
					for j in 0..<proximityEvents.count{
						if(dataRows[i]["Name"] as? String == proximityEvents[j]["Name"] as? String){
							proximityEvents[j] = dataRows[i]
							found = true
						}
					}
					if(found == false){
						proximityEvents.append(dataRows[i])
					}
					//proximityEvents.insert(dataRows[i], at: i)
				DispatchQueue.main.async(execute: {
						self.EventCollection.reloadData()
					})
				}

			}
		}
        //let closestBeacon = knownBeacons[0] as CLBeacon


    }

}

	
	
	let user = SFUserAccountManager.sharedInstance().currentUser
	let auth = SFAuthenticationManager.shared()
	@IBOutlet weak var CloseEvents: UITableView!
	@IBOutlet weak var fullName: UILabel!	
	@IBOutlet var EventCollection: UICollectionView!
	
	var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SFLogout(sender:)))
	
	func SFLogout(sender: UIBarButtonItem){
		auth.logout()
		//self.log(.debug, msg: "LOGOUT!")
	}
	//    @IBOutlet weak var txt: UITextField!
	//    @IBOutlet weak var userName: UILabel!
	//    @IBAction func Button(_ sender: Any) {
	//        self.userName.text = (user?.email)!
	//        self.log(.debug, msg: (user?.email)!)
	//    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "Home"
		navigationItem.rightBarButtonItem = logoutButton
		navigationItem.rightBarButtonItem?.target = self
		fullName.text = user?.fullName
		self.beaconManager.delegate = self
		if (SFUserAccountManager.sharedInstance().currentUser?.credentials.accessToken != nil)
		{
			self.beaconManager.requestAlwaysAuthorization()
		}
		
		self.CloseEvents.register(UITableViewCell.self, forCellReuseIdentifier:"cell")
		self.CloseEvents.dataSource=self
		self.CloseEvents.delegate=self
//		
//		self.EventCollection.register(EventCollectionViewCell.self, forCellWithReuseIdentifier: "EventCollectionCell")
//		self.EventCollection.dataSource=self
//		self.EventCollection.delegate=self
		//self.mail.text = user.email
		
		//self.userName.text = request.
		


	}
	var dataRows = [Dictionary<String, Any>]()
	var proximityEvents = [Dictionary<String, Any>]()
	
	override func loadView()
	{
		super.loadView()
		//self.title = "Mobile SDK Sample App"
		
		//Here we use a query that should work on either Force.com or Database.com
		let request = SFRestAPI.sharedInstance().request(forQuery:"SELECT Id,Description__c,Date__c,Image__c,Name,Event_Name__c,Major__c,Minor__c,Latitude__c,Longitude__c FROM Event__c ORDER BY CreatedDate DESC");
		SFRestAPI.sharedInstance().send(request, delegate: self);
	}
	
	func request(_ request: SFRestRequest, didLoadResponse jsonResponse: Any)
	{
		self.dataRows = ((jsonResponse as! NSDictionary)["records"] as! [NSDictionary]) as! [Dictionary<String,Any>] //(jsonResponse as! NSDictionary)["records"] as! [NSDictionary]
		self.log(.debug, msg: "request:didLoadResponse: #records: \(jsonResponse)")
//		for row in dataRows{
//			modifiedRows["Event_Name__c"] = row["Event_Name__c"] as! NSString as String
//		}
		proximityEvents.reserveCapacity(dataRows.count)
		DispatchQueue.main.async(execute: {
			self.CloseEvents.reloadData()
		})
	}
	//        func numberOfSectionsInTableView(EventTable: UITableView) -> Int
	//        {
	//            return 1
	//        }

	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(dataRows.count>0){
		return 1
		}else{
		return 0}
	}
	//var items=["Dog","Cat"]
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.CloseEvents.dequeueReusableCell(withIdentifier: "latestEvent")! as! latestEventCell
		let obj = dataRows[indexPath.row]
		let imageURL = URL(string: (obj["Image__c"] as? String)!)!
		let imgData = NSData(contentsOf:imageURL)!
		cell.myImage.image = UIImage(data:imgData as Data)
		if let distance = obj["Distance_From"] as? Int{
			cell.Distance!.text?.append(" < \(distance)m")
		}
		cell.eventName!.text = obj["Event_Name__c"] as? String
		cell.createdBy!.text = obj["CreatedById"] as? String
		
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
		
		let latDouble = (((obj["Latitude__c"] as? NSString)!).doubleValue)
		let lonDouble = (((obj["Longitude__c"] as? NSString)!).doubleValue)
		let eventCoordinates:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lonDouble,latDouble)
		let geoCoder = CLGeocoder()
		geoCoder.reverseGeocodeLocation(CLLocation(latitude: eventCoordinates.latitude,longitude: eventCoordinates.longitude), completionHandler: {
			(placemarks, error) -> Void in
			var placeMark: CLPlacemark!
			placeMark = placemarks?[0]
			if let zip = placeMark.addressDictionary!["City"] as? NSString {
				cell.createdBy!.text?.append((zip as String) as String + ",\n")
			}
			if let country = placeMark.addressDictionary!["Country"] as? NSString {
				cell.createdBy!.text?.append((country as String) as String)
			}
		})
		
		
		//cell.dateTime.text?.append(time!)
		//let distance = round((obj["Distance_From"] as? Double)!) (start: eventDate?.startIndex, end: eventDate?.endIndex)
		//cell.textLabel!.text = obj["Event_Name__c"] as? String
		//cell.textLabel!.text?.append("\(distance)")
		//self.log(.debug, msg: "RECORD:: \(obj["Name"] as? String)")
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
	}
	

	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		proximityEvents.sort {
			item1, item2 in
			let distance1 = item1["Distance_From"] as! Int
			let distance2 = item2["Distance_From"] as! Int
			return distance1 < distance2
			
		}
		return proximityEvents.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionCell", for: indexPath) as! EventCollectionViewCell
		let obj = proximityEvents[indexPath.row]
		let distance = ((obj["Distance_From"] as? Int)!)
		let imageURL = URL(string: (obj["Image__c"] as? String)!)!
		let imgData = NSData(contentsOf:imageURL)!
		collectionCell.image.image = UIImage(data:imgData as Data)
		collectionCell.eventDetail!.text = obj["Event_Name__c"] as? String
		collectionCell.distanceFrom!.text = ("Distance from event ± \(distance)m")
		if(obj["Temperature"] != nil){
		collectionCell.eventDetail!.text?.append(", : \((obj["Temperature"] as? Int)!)C")
		}
		//self.log(.debug, msg: "RECORD:: \(obj["Name"] as? String)")
		
		return collectionCell
	}
	

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.beaconManager.startRangingBeacons(in: self.beaconRegion)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.beaconManager.stopRangingBeacons(in: self.beaconRegion)
		proximityEvents.removeAll()
		DispatchQueue.main.async(execute: {
			self.CloseEvents.reloadData()
		})
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

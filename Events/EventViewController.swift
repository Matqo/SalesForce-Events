//
//  EventViewController.swift
//  Events
//
//  Created by Martin Futas on 05/03/2017.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit
import MapKit
import SalesforceSDKCore

class EventViewController: UIViewController, MKMapViewDelegate, SFRestDelegate {
    
    let user = SFUserAccountManager.sharedInstance().currentUser

    @IBOutlet weak var eventName: UILabel!
    
    var stringPassed = ""
    var ID = ""
    var longitude = ""
    var latitude = ""
    
    var address = ""

    @IBOutlet var mapView: MKMapView!
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//        let vc = storyboard.instantiateViewController(withIdentifier: "EventsScreen")
//        self.present(vc, animated: true, completion: nil);
    }
    
    func fetchData(_ sender : Any){
        let query = "SELECT Event_ID__c,User_ID__c FROM Events_Users__c WHERE Event_ID__c = \'"+ID+"\' AND User_ID__c = \'"+(user?.accountIdentity.userId)!+"\'"
        let request = SFRestAPI.sharedInstance().request(forQuery: query)
        SFRestAPI.sharedInstance().send(request, delegate: self);
        self.log(.debug, msg: "Query is: \(query)")
    }
    
    
    var dataRows = [NSDictionary]()
    
    func request(_ request: SFRestRequest, didLoadResponse jsonResponse: Any)
    {
        self.dataRows = (jsonResponse as! NSDictionary)["records"] as! [NSDictionary]
        populateView()
        if(self.dataRows.count>0){
            print("Is Attending !  !")
        }
    }
    
    
    func populateView(){
        print("ENTERS HERE")
        //let obj = dataRows[0]
        let latDouble = ((latitude as NSString)).doubleValue    //(((obj["Latitude__c"] as? NSString)!).doubleValue)
        let lonDouble = ((longitude as NSString)).doubleValue//(((obj["Longitude__c"] as? NSString)!).doubleValue)
        print(latDouble + lonDouble)
        let eventCoordinates:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lonDouble,latDouble)
        mapView.delegate=self
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: eventCoordinates.latitude,longitude: eventCoordinates.longitude), completionHandler: {
            (placemarks, error) -> Void in
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            if let street = placeMark.addressDictionary!["Name"] as? NSString {
                self.address.append(street as String + ",")
            }
            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                self.address.append( "\n" + (zip as String) as String + ",")
            }
            if let country = placeMark.addressDictionary!["Country"] as? NSString {
                self.address.append( "\n" + (country as String) as String)
            }
            let eventMapPin = MapAnnotation(title:self.stringPassed, subtitle:self.address as String!, coordinate: eventCoordinates)
            self.mapView.addAnnotation(eventMapPin)
        })
        
        
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(eventCoordinates, 2000, 2000), animated: true)
        //checkAttendance(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData(Any.self)
        navigationItem.title = stringPassed
        eventName.text = stringPassed
        
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

    if annotation is MKUserLocation {
        return nil
    }

    let reuseId = "pin"

    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.canShowCallout = true
    }
    else {
        pinView!.annotation = annotation
    }


    let subtitleView = UILabel()
    subtitleView.numberOfLines = 0
    subtitleView.text = address
    pinView!.detailCalloutAccessoryView = subtitleView


    return pinView
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

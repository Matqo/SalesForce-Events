//
//  EventsTests.swift
//  EventsTests
//
//  Created by Martin Futas on 22/04/2017.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import XCTest
@testable import Events

class EventsTests: XCTestCase {
	var myVc: MyEventsController!
	var rootVc: RootViewController!
	var eventViewVC : EventViewController
	var eventsVC: EventsController
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		myVc = storyboard.instantiateInitialViewController() as! MyEventsController
		rootVc = storyboard.instantiateInitialViewController() as! RootViewController
		eventViewVC = storyboard.instantiateInitialViewController() as! EventViewController
		eventsVC = storyboard.instantiateInitialViewController() as! EventsController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	// Testing that there is only 1 section in table
    func testTablerows() {
		let myNewDictArray: [Dictionary<String, Any>] = [["Key":"Value21"],["Keyy":"Value231"]]
        myVc.dataRows = myNewDictArray
		myVc.EventTable.reloadData()
		XCTAssertEqual(1,myVc.numberOfSections(in: myVc.EventTable))
    }
	
	// Testing to make sure that there is only 1 row in table, no matter how many sections & rows there are in total
	func testLatestEvent() {
		let myNewDictArray: [Dictionary<String, Any>] = [["Key":"Value1"],["Key":"Value2"]]
		rootVc.dataRows = myNewDictArray
		rootVc.CloseEvents.reloadData()
		XCTAssertEqual(1,rootVc.CloseEvents.numberOfRows(inSection: 1))
	}
	
	// If dictionaries are empty, there should be no sections made as there is no content to display
	func testMyEvents() {
		let dict1: [Dictionary<String, Any>] = []
		let dict2: [Dictionary<String, Any>] = []
		let dict3: [Dictionary<String, Any>] = []
		myVc.dataRows = dict1
		myVc.nDataRows = dict2
		myVc.proximityEvents = dict3
		myVc.EventTable.reloadData()
		XCTAssertEqual(0,myVc.EventTable.numberOfSections)
	}
	
	// Tests to see that date is set correctly 
	func testDateLabel() {
		eventViewVC.date = "2017-02-04"
		let cell = eventViewVC.tableView.dequeueReusableCell(withIdentifier: "1cell")! as! TitleTableViewCell
		eventViewVC.tableView.reloadData()
		XCTAssertEqual("Feb",cell.month.text)
	}
	
	// Testing that nearby events have distance label with value (not empty)
	func testNearby() {
		let cell = eventsVC.EventTable.dequeueReusableCell(withIdentifier: "customCell")! as! EventCell
		eventsVC.EventTable.reloadData()
		XCTAssertNotEqual("",cell.Distance.text)
	}
	
	
	
	
    
}

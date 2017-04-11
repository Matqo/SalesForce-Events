//
//  MapAnnotation.swift
//  Events
//
//  Created by Martin Futas on 29/03/2017.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title:String, subtitle:String, coordinate:CLLocationCoordinate2D) {
        self.title=title
        self.subtitle=subtitle
        self.coordinate=coordinate
    }

}

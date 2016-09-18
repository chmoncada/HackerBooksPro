//
//  MapLocation.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 17/09/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit
import MapKit

class MapLocation: NSObject, MKAnnotation {

    var title: String?
    var coordinate: CLLocationCoordinate2D
    var subtitle: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D, subtitle: String?) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = "Page \(subtitle!)"
    }
    
}
